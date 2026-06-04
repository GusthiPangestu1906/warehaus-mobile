import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/presentation/bloc/sales_order_bloc.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';

class SalesOrderListPage extends StatelessWidget {
  const SalesOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesOrderBloc, SalesOrderState>(
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
              message: 'Belum ada Sales Order.\nTap + untuk membuat baru.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.salesOrders.length,
            itemBuilder: (context, index) {
              return _SalesOrderCard(order: state.salesOrders[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SalesOrderCard extends StatelessWidget {
  final SalesOrder order;
  const _SalesOrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return WHColors.warning2;
      case 'processing':
        return WHColors.primary3;
      case 'completed':
        return WHColors.success2;
      case 'cancelled':
        return WHColors.error2;
      default:
        return WHColors.grey3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: WHColors.grey1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: WHColors.grey3),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.shippingAddress,
                    style: const TextStyle(color: WHColors.grey3, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 14, color: WHColors.grey3),
                const SizedBox(width: 4),
                Text(
                  order.courier,
                  style: const TextStyle(color: WHColors.grey3, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '${order.items.length} item',
                  style: const TextStyle(
                    color: WHColors.primary3,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
