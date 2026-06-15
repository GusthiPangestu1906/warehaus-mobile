import 'package:core_ui/core_ui.dart';
import 'package:outbound/domain/entities/sales_order.dart';

OrderStatus salesOrderViewStatus(SalesOrder order) {
  final status = order.status.trim().toLowerCase();

  if (order.isCompleted ||
      status == 'completed' ||
      status == 'complete' ||
      status == 'success' ||
      status == 'done' ||
      status == 'closed') {
    return OrderStatus.completed;
  }

  if (status == 'active' ||
      status == 'processing' ||
      status == 'picking' ||
      status == 'picking up' ||
      status == 'picked' ||
      status == 'packing' ||
      status == 'packed' ||
      status == 'in progress' ||
      (order.trackingNumber?.trim().isNotEmpty ?? false) ||
      order.totalPickedItems > 0 ||
      order.totalVerifiedItems > 0) {
    return OrderStatus.active;
  }

  return OrderStatus.queued;
}

OrderProcessStage salesOrderProcessStage(SalesOrder order) {
  final status = order.status.trim().toLowerCase();
  if (status.contains('pack') || order.totalVerifiedItems > 0) {
    return OrderProcessStage.packing;
  }
  return OrderProcessStage.pickingUp;
}

String salesOrderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.queued:
      return 'Queued';
    case OrderStatus.active:
      return 'Active';
    case OrderStatus.completed:
      return 'Completed';
  }
}
