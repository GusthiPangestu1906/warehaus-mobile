import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';
import 'package:outbound/presentation/models/sales_order_status_view.dart';
import 'package:outbound/presentation/pages/sales_order_detail_page.dart';

enum _OrderFilter { all, queued, active, completed }

class SalesOrderListPage extends StatefulWidget {
  const SalesOrderListPage({super.key});

  @override
  State<SalesOrderListPage> createState() => _SalesOrderListPageState();
}

class _SalesOrderListPageState extends State<SalesOrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _OrderFilter _filter = _OrderFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<SalesOrderBloc>().add(GetSalesOrdersEvent());
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: WHSearch(
            controller: _searchController,
            hintText: 'Search...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 28,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _OrderFilter.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _OrderFilter.values[index];
              return _FilterChip(
                label: _filterLabel(filter),
                isSelected: _filter == filter,
                onTap: () => setState(() => _filter = filter),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<SalesOrderBloc, SalesOrderState>(
            builder: (context, state) {
              if (state is SalesOrderLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SalesOrderError) {
                return _RefreshableEmpty(
                  onRefresh: _refresh,
                  message: state.message,
                );
              }

              if (state is SalesOrderLoaded) {
                final orders = _filteredOrders(state.salesOrders);

                if (state.salesOrders.isEmpty) {
                  return _RefreshableEmpty(
                    onRefresh: _refresh,
                    message:
                        'Belum ada Sales Order.\nTap + untuk membuat baru.',
                  );
                }

                if (orders.isEmpty) {
                  return _RefreshableEmpty(
                    onRefresh: _refresh,
                    message: 'Sales Order tidak ditemukan.',
                  );
                }

                return WHRefresh(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        data: _toCardData(order),
                        onTap: () {
                          final bloc = context.read<SalesOrderBloc>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: SalesOrderDetailPage(order: order),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

              return _RefreshableEmpty(
                onRefresh: _refresh,
                message: 'Belum ada Sales Order.\nTap + untuk membuat baru.',
              );
            },
          ),
        ),
      ],
    );
  }

  List<SalesOrder> _filteredOrders(List<SalesOrder> orders) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = orders.where((order) {
      final status = salesOrderViewStatus(order);
      final matchesFilter =
          _filter == _OrderFilter.all ||
          (_filter == _OrderFilter.queued && status == OrderStatus.queued) ||
          (_filter == _OrderFilter.active && status == OrderStatus.active) ||
          (_filter == _OrderFilter.completed &&
              status == OrderStatus.completed);

      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      final searchable = [
        order.soNumber,
        order.customerName,
        order.companyName,
        order.contactPerson,
        order.courierName,
        order.status,
      ].whereType<String>().join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();

    filtered.sort((a, b) => a.id.compareTo(b.id));
    return filtered;
  }

  OrderCardData _toCardData(SalesOrder order) {
    final status = salesOrderViewStatus(order);
    final total = order.totalOrderedQuantity > 0
        ? order.totalOrderedQuantity
        : order.items.fold<int>(0, (sum, item) => sum + item.qtyOrdered);
    final processStage = salesOrderProcessStage(order);
    final processValue = processStage == OrderProcessStage.packing
        ? order.totalVerifiedItems
        : order.totalPickedItems;

    return OrderCardData(
      orderNumber: _formatSalesOrderNumber(order),
      type: OrderType.outbound,
      status: status,
      createdAt: _formatDate(order.orderDate),
      carrierOrCourier: _shortCourierName(order.courierName),
      processStage: status == OrderStatus.active ? processStage : null,
      processValue: processValue,
      processTotal: total,
      processUnit: 'Pallets',
    );
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '-';
    final local = parsed.toLocal();
    return DateFormat('dd MMMM yyyy').format(local);
  }

  String _formatSalesOrderNumber(SalesOrder order) {
    final parsed = DateTime.tryParse(order.orderDate);
    if (parsed == null) return order.soNumber;

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final sequence = order.id.toString().padLeft(2, '0');

    return 'SO-$day$month${local.year}-$sequence';
  }

  String _shortCourierName(String? value) {
    final courier = value?.trim();
    if (courier == null || courier.isEmpty) return '-';
    return courier.split(' ').first;
  }

  String _filterLabel(_OrderFilter filter) {
    switch (filter) {
      case _OrderFilter.all:
        return 'All';
      case _OrderFilter.queued:
        return 'Queued';
      case _OrderFilter.active:
        return 'Active';
      case _OrderFilter.completed:
        return 'Completed';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? WHColors.primary1 : WHColors.primary6,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? WHColors.primary1 : WHColors.primary5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? WHColors.surface : WHColors.grey1,
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshableEmpty extends StatelessWidget {
  const _RefreshableEmpty({required this.onRefresh, required this.message});

  final Future<void> Function() onRefresh;
  final String message;

  @override
  Widget build(BuildContext context) {
    return WHRefresh(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.52,
          child: WHEmptyState(message: message),
        ),
      ),
    );
  }
}
