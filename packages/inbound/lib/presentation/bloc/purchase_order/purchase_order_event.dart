import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/domain/params/submit_qc_params.dart';

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

class DownloadPurchaseOrderPdfEvent extends PurchaseOrderEvent {
  final int id;
  final String poNumber;

  DownloadPurchaseOrderPdfEvent(this.id, this.poNumber);
}

class GetQcNextItemEvent extends PurchaseOrderEvent {
  final int poId;
  GetQcNextItemEvent(this.poId);
}

class SubmitQcEvent extends PurchaseOrderEvent {
  final SubmitQcParams params;
  SubmitQcEvent(this.params);
}

class GetPaNextItemEvent extends PurchaseOrderEvent {
  final int poId;
  GetPaNextItemEvent(this.poId);
}

class SubmitPaEvent extends PurchaseOrderEvent {
  final SubmitPaParams params;
  final int receivingLogId;
  SubmitPaEvent(this.params, this.receivingLogId);
}

class GetCarriersEvent extends PurchaseOrderEvent {}
