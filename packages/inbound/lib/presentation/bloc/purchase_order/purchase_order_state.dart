import 'package:equatable/equatable.dart';
import 'package:inbound/domain/entities/purchase_order.dart';

sealed class PurchaseOrderState extends Equatable {
  const PurchaseOrderState();

  @override
  List<Object?> get props => [];
}

class PurchaseOrderInitial extends PurchaseOrderState {}

class PurchaseOrderLoading extends PurchaseOrderState {}

class PurchaseOrderLoaded extends PurchaseOrderState {
  final List<PurchaseOrder> purchaseOrders;
  const PurchaseOrderLoaded(this.purchaseOrders);

  @override
  List<Object?> get props => [purchaseOrders];
}

class PurchaseOrderDetailLoaded extends PurchaseOrderState {
  final PurchaseOrder purchaseOrder;
  const PurchaseOrderDetailLoaded(this.purchaseOrder);

  @override
  List<Object?> get props => [purchaseOrder];
}

class CreatePurchaseOrderSuccess extends PurchaseOrderState {}

class UpdatePurchaseOrderSuccess extends PurchaseOrderState {}

class UpdateInvoiceSuccess extends PurchaseOrderState {}

class DeletePurchaseOrderSuccess extends PurchaseOrderState {}

class DownloadPurchaseOrderPdfSuccess extends PurchaseOrderState {
  final String filePath;
  const DownloadPurchaseOrderPdfSuccess(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class PurchaseOrderActionError extends PurchaseOrderState {
  final String message;
  const PurchaseOrderActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class PurchaseOrderError extends PurchaseOrderState {
  final String message;
  const PurchaseOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
