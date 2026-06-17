import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_bloc.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';
import 'package:inbound/presentation/pages/create_purchase_order_page.dart';
import 'package:inbound/presentation/pages/purchase_order_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_state.dart';
import 'package:mobile/route_observer.dart';
import 'package:outbound/outbound.dart';

enum _OrderFilter { all, queued, active, completed }

class FlowManagementPage extends StatefulWidget {
  const FlowManagementPage({super.key});

  @override
  State<FlowManagementPage> createState() => _FlowManagementPageState();
}

class _FlowManagementPageState extends State<FlowManagementPage>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  late SalesOrderBloc _salesOrderBloc;
  late PurchaseOrderBloc _purchaseOrderBloc;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _OrderFilter _filter = _OrderFilter.all;
  DateTime? _selectedDate;

  List<SalesOrder>? _lastSalesOrders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _salesOrderBloc = GetIt.instance<SalesOrderBloc>()
      ..add(GetSalesOrdersEvent());
    _purchaseOrderBloc = GetIt.instance<PurchaseOrderBloc>()
      ..add(GetPurchaseOrdersEvent(date: _selectedDate));

    _tabController.addListener(() => setState(() {}));
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
    _tabController.dispose();
    _searchController.dispose();
    _salesOrderBloc.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    final navigationState = context.read<NavigationBloc>().state;
    if (navigationState.currentIndex == 2) {
      _fetchOrders();
    }
  }

  void _onFabPressed() {
    final isOutbound = _tabController.index == 1;

    if (isOutbound) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => BlocProvider.value(
            value: _salesOrderBloc,
            child: const CreateSalesOrderPage(),
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => BlocProvider.value(
            value: _purchaseOrderBloc,
            child: const CreatePurchaseOrderPage(),
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
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

  Future<void> _fetchOrders() async {
    // Format date as ISO8601 string (same as purchase order API)
    final dateString = _selectedDate != null
        ? (_selectedDate!.isUtc ? _selectedDate! : _selectedDate!.toUtc())
              .toIso8601String()
        : null;

    _purchaseOrderBloc.add(GetPurchaseOrdersEvent(date: _selectedDate));
    _salesOrderBloc.add(GetSalesOrdersEvent(date: dateString));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _salesOrderBloc),
        BlocProvider.value(value: _purchaseOrderBloc),
      ],
      child: BlocListener<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state.currentIndex == 2) {
            _fetchOrders();
          }
        },
        child: Scaffold(
          backgroundColor: WHColors.background,
          appBar: const WHAppbar(title: 'FLOW MANAGEMENT'),
          body: Column(
            children: [
              // Tab Bar INBOUND / OUTBOUND
              Container(
                color: WHColors.surface,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: WHColors.secondary3,
                  indicatorWeight: 3,
                  labelColor: WHColors.grey1,
                  unselectedLabelColor: WHColors.grey1,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: 'INBOUND'),
                    Tab(text: 'OUTBOUND'),
                  ],
                ),
              ),

              // Search Bar with Date Filter
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: WHSearch(
                        controller: _searchController,
                        hintText:
                            'Search by order number, customer/supplier, or status',
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
              ),

              // Date Filter Summary
              if (_selectedDate != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DateFilterSummary(
                    label: DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    onClear: _clearFilterDate,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Filter Chips
              SizedBox(
                height: 28,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // INBOUND TAB
                    _InboundTabContent(
                      searchQuery: _searchQuery,
                      filter: _filter,
                      selectedDate: _selectedDate,
                      onRefresh: _fetchOrders,
                    ),
                    // OUTBOUND TAB
                    BlocBuilder<SalesOrderBloc, SalesOrderState>(
                      builder: (context, state) {
                        if (state is SalesOrderLoaded) {
                          _lastSalesOrders = state.salesOrders;
                        }

                        final salesOrdersToShow = _lastSalesOrders;
                        if (salesOrdersToShow != null) {
                          final orders = _filteredOutboundOrders(
                            salesOrdersToShow,
                          );

                          if (salesOrdersToShow.isEmpty) {
                            return _RefreshableEmpty(
                              onRefresh: () => _fetchOrders(),
                              message:
                                  'Belum ada Sales Order.\nTap + untuk membuat baru.',
                            );
                          }

                          if (orders.isEmpty) {
                            return _RefreshableEmpty(
                              onRefresh: () => _fetchOrders(),
                              message: 'Sales Order tidak ditemukan.',
                            );
                          }

                          return WHRefresh(
                            onRefresh: () => _fetchOrders(),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                              itemCount: orders.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return OrderCard(
                                  data: _toOutboundCardData(order),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: _salesOrderBloc,
                                          child: SalesOrderDetailPage(
                                            order: order,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }

                        if (state is SalesOrderLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is SalesOrderError) {
                          return _RefreshableEmpty(
                            onRefresh: () => _fetchOrders(),
                            message: state.message,
                          );
                        }
                        return _RefreshableEmpty(
                          onRefresh: () => _fetchOrders(),
                          message:
                              'Belum ada Sales Order.\nTap + untuk membuat baru.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'flow-create-fab',
            onPressed: _onFabPressed,
            backgroundColor: WHColors.primary3,
            child: const Icon(Icons.add, color: WHColors.surface),
          ),
        ),
      ),
    );
  }

  List<SalesOrder> _filteredOutboundOrders(List<SalesOrder> orders) {
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

  OrderCardData _toOutboundCardData(SalesOrder order) {
    final status = salesOrderViewStatus(order);
    final total = order.totalOrderedQuantity > 0
        ? order.totalOrderedQuantity
        : order.items.fold<int>(0, (sum, item) => sum + item.qtyOrdered);
    final processStage = salesOrderProcessStage(order);
    final processValue = processStage == OrderProcessStage.packing
        ? order.totalVerifiedItems
        : order.totalPickedItems;

    return OrderCardData(
      orderNumber: order.soNumber,
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
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
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

// DATE FILTER BUTTON
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

// DATE FILTER SUMMARY
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

// INBOUND TAB CONTENT
class _InboundTabContent extends StatefulWidget {
  final String searchQuery;
  final _OrderFilter filter;
  final DateTime? selectedDate;
  final Future<void> Function() onRefresh;

  const _InboundTabContent({
    required this.searchQuery,
    required this.filter,
    required this.selectedDate,
    required this.onRefresh,
  });

  @override
  State<_InboundTabContent> createState() => _InboundTabContentState();
}

class _InboundTabContentState extends State<_InboundTabContent> {
  List<PurchaseOrder>? _lastOrders;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseOrderBloc, PurchaseOrderState>(
      builder: (context, state) {
        if (state is PurchaseOrderLoaded) {
          _lastOrders = state.purchaseOrders;
        }

        final ordersToShow = _lastOrders;
        if (ordersToShow != null) {
          final orders = _filteredInboundOrders(ordersToShow);

          if (ordersToShow.isEmpty) {
            return _RefreshableEmpty(
              onRefresh: widget.onRefresh,
              message: 'Belum ada Purchase Order.\nTap + untuk membuat baru.',
            );
          }

          if (orders.isEmpty) {
            return _RefreshableEmpty(
              onRefresh: widget.onRefresh,
              message: 'Purchase Order tidak ditemukan.',
            );
          }

          return WHRefresh(
            onRefresh: widget.onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  data: _toInboundCardData(order),
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
                          if (!context.mounted || result == null) return;
                          context.read<PurchaseOrderBloc>().add(
                            GetPurchaseOrdersEvent(date: widget.selectedDate),
                          );

                          final message =
                              result == PurchaseOrderDetailResult.deleted
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

        if (state is PurchaseOrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PurchaseOrderError) {
          return _RefreshableEmpty(
            onRefresh: widget.onRefresh,
            message: state.message,
          );
        }

        return _RefreshableEmpty(
          onRefresh: widget.onRefresh,
          message: 'Belum ada Purchase Order.\nTap + untuk membuat baru.',
        );
      },
    );
  }

  List<PurchaseOrder> _filteredInboundOrders(List<PurchaseOrder> orders) {
    final query = widget.searchQuery.trim().toLowerCase();

    final filtered = orders.where((order) {
      final status = _mapOrderStatus(order.status);
      final matchesFilter =
          widget.filter == _OrderFilter.all ||
          (widget.filter == _OrderFilter.queued && status == OrderStatus.queued) ||
          (widget.filter == _OrderFilter.active && status == OrderStatus.active) ||
          (widget.filter == _OrderFilter.completed && status == OrderStatus.completed);

      if (!matchesFilter) return false;
      if (query.isEmpty) return true;

      final searchable = [
        order.poNumber,
        order.supplierName,
        order.status,
      ].whereType<String>().join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();

    return filtered;
  }

  OrderCardData _toInboundCardData(PurchaseOrder order) {
    final status = _mapOrderStatus(order.status);
    final formattedDate = DateFormat('dd/MM/yyyy').format(order.createdAt);

    return OrderCardData(
      orderNumber: order.poNumber,
      type: OrderType.inbound,
      status: status,
      createdAt: formattedDate,
      carrierOrCourier: order.carrier,
      processStage: order.isQcCompleted == true
          ? OrderProcessStage.puttingAway
          : OrderProcessStage.qc,
      processValue: order.isQcCompleted == true
          ? order.putAwayCompletedCount
          : order.qcCompletedCount,
      processTotal: order.totalItemCount,
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

// FILTER CHIP WIDGET
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

// REFRESHABLE EMPTY WIDGET
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
