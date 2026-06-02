abstract class PurchaseOrderState {
  const PurchaseOrderState();
}

class PurchaseOrderInitial extends PurchaseOrderState {}

class PurchaseOrderLoading extends PurchaseOrderState {}

class CreatePurchaseOrderSuccess extends PurchaseOrderState {}

class PurchaseOrderError extends PurchaseOrderState {
  final String message;

  const PurchaseOrderError(this.message);
}
