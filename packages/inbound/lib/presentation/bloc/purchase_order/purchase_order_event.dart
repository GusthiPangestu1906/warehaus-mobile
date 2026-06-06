import 'package:inbound/domain/params/create_po_params.dart';

abstract class PurchaseOrderEvent {}

class GetPurchaseOrdersEvent extends PurchaseOrderEvent {}

class GetPurchaseOrderDetailEvent extends PurchaseOrderEvent {
  final int id;
  GetPurchaseOrderDetailEvent(this.id);
}

class CreatePurchaseOrderEvent extends PurchaseOrderEvent {
  final CreatePoParams params;
  CreatePurchaseOrderEvent(this.params);
}

class UpdateInvoiceEvent extends PurchaseOrderEvent {
  final int id;
  final String invoiceNumber;
  UpdateInvoiceEvent(this.id, this.invoiceNumber);
}

class DeletePurchaseOrderEvent extends PurchaseOrderEvent {
  final int id;
  DeletePurchaseOrderEvent(this.id);
}
