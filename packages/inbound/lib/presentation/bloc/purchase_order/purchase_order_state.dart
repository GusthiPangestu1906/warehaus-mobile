import 'package:inbound/domain/entities/purchase_order.dart';

abstract class PurchaseOrderState {
  const PurchaseOrderState();
}

class PurchaseOrderInitial extends PurchaseOrderState {}

class PurchaseOrderLoading extends PurchaseOrderState {}

class PurchaseOrderLoaded extends PurchaseOrderState {
  final List<PurchaseOrder> purchaseOrders;

  const PurchaseOrderLoaded(this.purchaseOrders);
}

class PurchaseOrderDetailLoaded extends PurchaseOrderState {
  final PurchaseOrder purchaseOrder;

  const PurchaseOrderDetailLoaded(this.purchaseOrder);
}

class CreatePurchaseOrderSuccess extends PurchaseOrderState {}

class UpdateInvoiceSuccess extends PurchaseOrderState {}

class DeletePurchaseOrderSuccess extends PurchaseOrderState {}

class PurchaseOrderError extends PurchaseOrderState {
  final String message;

  const PurchaseOrderError(this.message);
}
