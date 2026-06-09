import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:zone/presentation/pages/create_zone_page.dart';
import 'package:product/presentation/pages/create_product_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Mock data for UI development
  final List<Map<String, dynamic>> mockLogs = [
    {
      'productName': 'Indomie Goreng',
      'sku': 'SKU-001',
      'locationName': 'A-12',
      'quantity': 50,
      'stockAfterMovement': 1250,
      'isStockIn': true,
      'time': '10:45 AM',
    },
    {
      'productName': 'Mineral Water 600ml',
      'sku': 'SKU-002',
      'locationName': 'B-04',
      'quantity': 20,
      'stockAfterMovement': 480,
      'isStockIn': false,
      'time': '09:30 AM',
    },
    {
      'productName': 'Cooking Oil 2L',
      'sku': 'SKU-003',
      'locationName': 'C-01',
      'quantity': 100,
      'stockAfterMovement': 2100,
      'isStockIn': true,
      'time': '08:15 AM',
    },
  ];

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
                      icon: Icons.assignment_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'TOTAL PRODUCTS',
                      value: '1,240',
                      subtitle: 'Items Registered',
                      icon: Icons.inventory_2_outlined,
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
                      color: WHColors.primary3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOperationCard(
                      title: 'Add Zone',
                      icon: Icons.layers_outlined,
                      color: WHColors.secondary3,
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
                      color: WHColors.primary3,
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

              // Mock Logs List
              ...mockLogs.map((log) => _buildLogItem(log)),
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
    required IconData icon,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WHColors.secondary3.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: WHColors.secondary3, size: 20),
          ),
          const SizedBox(height: 12),
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
            color: WHColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: WHColors.grey5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: WHTypography.caption.copyWith(
                  color: WHColors.grey2,
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

  Widget _buildLogItem(Map<String, dynamic> log) {
    final bool isStockIn = log['isStockIn'];
    final color = isStockIn ? WHColors.primary3 : WHColors.secondary3;
    final icon = isStockIn ? Icons.arrow_downward : Icons.arrow_upward;
    final label = isStockIn ? 'Stock In' : 'Stock Out';

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
            padding: const EdgeInsets.all(10),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: WHTypography.caption.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log['productName'],
                        style: WHTypography.bodyText.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${log['sku']} • ${log['locationName']}',
                  style: WHTypography.caption.copyWith(color: WHColors.grey2),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Qty: ${log['quantity']} → After: ${log['stockAfterMovement']}',
                  style: WHTypography.caption.copyWith(color: WHColors.grey2),
                ),
              ],
            ),
          ),
          Text(
            log['time'],
            style: WHTypography.caption.copyWith(color: WHColors.grey2),
          ),
        ],
      ),
    );
  }
}
