import 'package:equatable/equatable.dart';
import 'package:inbound/domain/params/create_po_params.dart';

sealed class PurchaseOrderEvent extends Equatable {
  const PurchaseOrderEvent();

  @override
  List<Object?> get props => [];
}

class GetPurchaseOrdersEvent extends PurchaseOrderEvent {
  final DateTime? date;
  const GetPurchaseOrdersEvent({this.date});

  @override
  List<Object?> get props => [date];
}

class GetPurchaseOrderDetailEvent extends PurchaseOrderEvent {
  final int id;
  const GetPurchaseOrderDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreatePurchaseOrderEvent extends PurchaseOrderEvent {
  final CreatePoParams params;
  const CreatePurchaseOrderEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class UpdatePurchaseOrderEvent extends PurchaseOrderEvent {
  final int id;
  final CreatePoParams params;
  const UpdatePurchaseOrderEvent(this.id, this.params);

  @override
  List<Object?> get props => [id, params];
}

class UpdateInvoiceEvent extends PurchaseOrderEvent {
  final int id;
  final String invoiceNumber;
  const UpdateInvoiceEvent(this.id, this.invoiceNumber);

  @override
  List<Object?> get props => [id, invoiceNumber];
}

class DeletePurchaseOrderEvent extends PurchaseOrderEvent {
  final int id;
  const DeletePurchaseOrderEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DownloadPurchaseOrderPdfEvent extends PurchaseOrderEvent {
  final int id;
  final String poNumber;
  const DownloadPurchaseOrderPdfEvent(this.id, this.poNumber);

  @override
  List<Object?> get props => [id, poNumber];
}
