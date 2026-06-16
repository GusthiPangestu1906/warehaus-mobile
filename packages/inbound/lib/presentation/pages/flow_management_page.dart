import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:inbound/presentation/pages/create_purchase_order_page.dart';
import 'package:inbound/presentation/widgets/flow_tab_content.dart';
import 'package:outbound/outbound.dart';

class FlowManagementPage extends StatefulWidget {
  const FlowManagementPage({super.key});

  @override
  State<FlowManagementPage> createState() => _FlowManagementPageState();
}

class _FlowManagementPageState extends State<FlowManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SalesOrderBloc _salesOrderBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _salesOrderBloc = GetIt.instance<SalesOrderBloc>()
      ..add(GetSalesOrdersEvent());

    // Rebuild FAB saat tab berubah
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _salesOrderBloc.close();
    super.dispose();
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
          pageBuilder: (_, _, _) => const CreatePurchaseOrderPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _salesOrderBloc,
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: WHSearch(
                controller: _searchController,
                hintText: 'Search...',
                onChanged: (value) {
                  // TODO: implement search filter
                },
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const FlowTabContent(type: FlowType.inbound),
                  BlocBuilder<SalesOrderBloc, SalesOrderState>(
                    builder: (context, state) {
                      if (state is SalesOrderLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is SalesOrderError) {
                        return WHEmptyState(message: state.message);
                      }
                      if (state is SalesOrderLoaded) {
                        if (state.salesOrders.isEmpty) {
                          return const WHEmptyState(
                            message:
                                'Belum ada Sales Order.\nTap + untuk membuat baru.',
                          );
                        }
                        return const SalesOrderListPage();
                      }
                      return const WHEmptyState(
                        message: 'Belum ada Sales Order.\nTap + untuk membuat baru.',
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
    );
  }
}
