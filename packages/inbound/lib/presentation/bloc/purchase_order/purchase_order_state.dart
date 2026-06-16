import 'package:inbound/domain/entities/carrier.dart';
import 'package:inbound/domain/entities/pa_next_item.dart';
import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/domain/entities/qc_next_item.dart';

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

class UpdatePurchaseOrderSuccess extends PurchaseOrderState {}

class UpdateInvoiceSuccess extends PurchaseOrderState {}

class DeletePurchaseOrderSuccess extends PurchaseOrderState {}

class DownloadPurchaseOrderPdfSuccess extends PurchaseOrderState {
  final String filePath;

  const DownloadPurchaseOrderPdfSuccess(this.filePath);
}

class PurchaseOrderActionError extends PurchaseOrderState {
  final String message;

  const PurchaseOrderActionError(this.message);
}

class QcNextItemLoaded extends PurchaseOrderState {
  final QcNextItem item;

  const QcNextItemLoaded(this.item);
}

class SubmitQcSuccess extends PurchaseOrderState {}

class PaNextItemLoaded extends PurchaseOrderState {
  final PaNextItem item;

  const PaNextItemLoaded(this.item);
}

class SubmitPaSuccess extends PurchaseOrderState {}

class CarriersLoaded extends PurchaseOrderState {
  final List<Carrier> carriers;

  const CarriersLoaded(this.carriers);
}

class PurchaseOrderError extends PurchaseOrderState {
  final String message;

  const PurchaseOrderError(this.message);
}
