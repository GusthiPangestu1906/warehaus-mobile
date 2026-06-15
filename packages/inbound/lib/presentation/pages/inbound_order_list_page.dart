import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';
import 'package:inbound/presentation/pages/create_purchase_order_page.dart';
import 'package:inbound/presentation/pages/purchase_order_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/route_observer.dart';

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({required this.isActive, required this.onPressed});

  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Material(
        color: isActive ? WHColors.primary3 : WHColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? WHColors.primary3 : WHColors.grey5,
              ),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: isActive ? WHColors.surface : WHColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateFilterSummary extends StatelessWidget {
  const _DateFilterSummary({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            color: WHColors.primary3,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtered by date: $label',
              style: WHTypography.caption.copyWith(
                color: WHColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                color: WHColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InboundOrderListPage extends StatefulWidget {
  const InboundOrderListPage({super.key});

  @override
  State<InboundOrderListPage> createState() => _InboundOrderListPageState();
}

class _InboundOrderListPageState extends State<InboundOrderListPage>
    with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchOrders();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    final navigationState = context.read<NavigationBloc>().state;
    if (navigationState.currentIndex == 2) {
      _fetchOrders();
    }
  }

  void _fetchOrders() {
    context.read<PurchaseOrderBloc>().add(
      GetPurchaseOrdersEvent(date: _selectedDate),
    );
  }

  Future<void> _pickFilterDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: WHColors.primary3,
              onPrimary: WHColors.surface,
              onSurface: WHColors.textPrimary,
              surface: WHColors.surface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: WHColors.primary3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime.utc(picked.year, picked.month, picked.day);
    });
    _fetchOrders();
  }

  void _clearFilterDate() {
    setState(() => _selectedDate = null);
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHColors.background,
      appBar: WHAppbar(title: 'FLOW MANAGEMENT'),
      body: Container(
        color: WHColors.background,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: WHSearch(
                    hintText: 'Search by PO number, supplier, or status',
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                _DateFilterButton(
                  isActive: _selectedDate != null,
                  onPressed: _pickFilterDate,
                ),
              ],
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 10),
              _DateFilterSummary(
                label: DateFormat('dd/MM/yyyy').format(_selectedDate!),
                onClear: _clearFilterDate,
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<PurchaseOrderBloc, PurchaseOrderState>(
                builder: (context, state) {
                  if (state is PurchaseOrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PurchaseOrderError) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: WHError(message: state.message),
                    );
                  }

                  if (state is PurchaseOrderLoaded) {
                    if (state.purchaseOrders.isEmpty) {
                      return WHRefresh(
                        onRefresh: () async {
                          _fetchOrders();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const WHEmptyState(
                              message:
                                  "No purchase orders found.\nTap the + button to create one.",
                            ),
                          ),
                        ),
                      );
                    }

                    final query = _searchQuery.trim().toLowerCase();
                    final filteredOrders = query.isEmpty
                        ? state.purchaseOrders
                        : state.purchaseOrders.where((order) {
                            return order.poNumber.toLowerCase().contains(
                                  query,
                                ) ||
                                order.supplierName.toLowerCase().contains(
                                  query,
                                ) ||
                                order.status.toLowerCase().contains(query);
                          }).toList();

                    if (filteredOrders.isEmpty) {
                      return WHRefresh(
                        onRefresh: () async {
                          _fetchOrders();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const WHEmptyState(
                              message: 'No purchase orders match your search.',
                            ),
                          ),
                        ),
                      );
                    }

                    return WHRefresh(
                      onRefresh: () async {
                        _fetchOrders();
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final String formattedDate = DateFormat(
                            'dd/MM/yyyy',
                          ).format(order.createdAt);

                          return OrderCard(
                            data: OrderCardData(
                              orderNumber: order.poNumber,
                              type: OrderType.inbound,
                              status: _mapOrderStatus(order.status),
                              createdAt: formattedDate,
                              carrierOrCourier: order.carrier,
                              processStage: order.isQcCompleted == true
                                  ? OrderProcessStage.puttingAway
                                  : OrderProcessStage.qc,
                              processValue: order.isQcCompleted == true
                                  ? order.putAwayCompletedCount
                                  : order.qcCompletedCount,
                              processTotal: order.totalItemCount,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .push<PurchaseOrderDetailResult>(
                                    MaterialPageRoute(
                                      builder: (_) => PurchaseOrderDetailPage(
                                        purchaseOrderId: order.id,
                                      ),
                                    ),
                                  )
                                  .then((result) {
                                    if (!context.mounted || result == null) {
                                      return;
                                    }

                                    _fetchOrders();

                                    final message =
                                        result ==
                                            PurchaseOrderDetailResult.deleted
                                        ? 'Purchase Order has been successfully deleted.'
                                        : 'Invoice has been successfully saved.';

                                    WHSnackBar.showSuccess(context, message);
                                  });
                            },
                          );
                        },
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'inbound-create-po-fab',
        onPressed: () async {
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const CreatePurchaseOrderPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        backgroundColor: WHColors.primary3,
        child: const Icon(Icons.add, color: WHColors.surface),
      ),
    );
  }

  OrderStatus _mapOrderStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return OrderStatus.active;
      case 'completed':
      case 'success':
        return OrderStatus.completed;
      case 'pending':
      case 'queued':
      default:
        return OrderStatus.queued;
    }
  }
}
