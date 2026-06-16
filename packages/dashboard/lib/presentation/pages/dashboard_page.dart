import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:zone/presentation/pages/create_zone_page.dart';
import 'package:product/presentation/pages/create_product_page.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:dashboard/services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardService _service;
  List<ActivityLog> _logs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = DashboardService(GetIt.instance<Dio>());
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      setState(() => _isLoading = true);
      final logs = await _service.getRecentLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHColors.background,
      appBar: const WHAppbar(title: 'WAREHAUS'),
      body: WHRefresh(
        onRefresh: () async {
          // Placeholder for refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'PENDING TASKS',
                      value: '15',
                      subtitle: 'Tasks Waiting',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'TOTAL PRODUCTS',
                      value: '1,240',
                      subtitle: 'Items Registered',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Text(
                'OPERATIONS',
                style: WHTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: WHColors.grey2,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildOperationCard(
                      title: 'Create PO',
                      icon: Icons.description_outlined,
                      color: WHColors.surface,
                      bgColor: WHColors.secondary4,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateZonePage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOperationCard(
                      title: 'Add Zone',
                      icon: Icons.layers_outlined,
                      color: WHColors.secondary3,
                      bgColor: WHColors.surface,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const CreateZonePage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOperationCard(
                      title: 'Add Product',
                      icon: Icons.inventory_2_outlined,
                      color: WHColors.secondary3,
                      bgColor: WHColors.surface,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const CreateProductPage()
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOperationCard(
                      title: 'Create SO',
                      icon: Icons.assignment_outlined,
                      color: WHColors.surface,
                      bgColor: WHColors.secondary4,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateZonePage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // Recent Activity Header
              Text(
                'RECENT LOGS',
                style: WHTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: WHColors.grey2,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: WHColors.grey5),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Center(child: Text('Error: $_error'))
              else if (_logs.isEmpty)
                const Center(child: Text('No recent logs found.'))
              else
                ..._logs.map((log) => _buildLogItem(log)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: WHTypography.caption.copyWith(
              color: WHColors.grey2,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: WHTypography.heading1.copyWith(
              color: WHColors.secondary3,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: WHTypography.caption.copyWith(
              color: WHColors.grey2,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: WHColors.grey5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: WHColors.textPrimary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: WHTypography.caption.copyWith(
                  color: WHColors.grey1,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(ActivityLog log) {
    final color = log.isStockIn ? WHColors.primary3 : WHColors.secondary3;
    final icon = log.isStockIn ? Icons.login_rounded : Icons.logout_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WHColors.grey5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title, // e.g., "Put Away - AP-1-1"
                  style: WHTypography.bodyText.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  log.subtitle, // e.g., "Order: PO-10062026-2 - Permen Melati Enak"
                  style: WHTypography.caption.copyWith(color: WHColors.grey2),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            'log.time',
            style: WHTypography.caption.copyWith(color: WHColors.grey2),
          ),
        ],
      ),
    );
  }
}
