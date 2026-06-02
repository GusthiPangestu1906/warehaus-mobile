import 'package:inbound/domain/params/create_po_params.dart';

abstract class PurchaseOrderEvent {}

class CreatePurchaseOrderEvent extends PurchaseOrderEvent {
  final CreatePoParams params;
  CreatePurchaseOrderEvent(this.params);
}
