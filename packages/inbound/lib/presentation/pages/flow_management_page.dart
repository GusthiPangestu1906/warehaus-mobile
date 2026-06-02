import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:inbound/presentation/widgets/flow_tab_content.dart';

class FlowManagementPage extends StatefulWidget {
  const FlowManagementPage({super.key});

  @override
  State<FlowManagementPage> createState() => _FlowManagementPageState();
}

class _FlowManagementPageState extends State<FlowManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // TODO: implement search
              },
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FlowTabContent(type: FlowType.inbound),
                FlowTabContent(type: FlowType.outbound),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'flow-create-fab',
        onPressed: () {
          // TODO: handle create based on current tab
        },
        backgroundColor: WHColors.primary3,
        child: const Icon(Icons.add, color: WHColors.surface),
      ),
    );
  }
}