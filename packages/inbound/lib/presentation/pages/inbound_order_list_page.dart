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

class InboundOrderListPage extends StatefulWidget {
  const InboundOrderListPage({super.key});

  @override
  State<InboundOrderListPage> createState() => _InboundOrderListPageState();
}

class _InboundOrderListPageState extends State<InboundOrderListPage>
    with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PurchaseOrderBloc>().add(GetPurchaseOrdersEvent());
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
      context.read<PurchaseOrderBloc>().add(GetPurchaseOrdersEvent());
    }
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
            WHSearch(
              hintText: 'Search by PO number, supplier, or status',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
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
                          context.read<PurchaseOrderBloc>().add(
                            GetPurchaseOrdersEvent(),
                          );
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
                          context.read<PurchaseOrderBloc>().add(
                            GetPurchaseOrdersEvent(),
                          );
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
                        context.read<PurchaseOrderBloc>().add(
                          GetPurchaseOrdersEvent(),
                        );
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

                                    context.read<PurchaseOrderBloc>().add(
                                      GetPurchaseOrdersEvent(),
                                    );

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
