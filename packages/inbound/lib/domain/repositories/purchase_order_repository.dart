import 'package:inbound/domain/params/create_po_params.dart';

abstract class PurchaseOrderRepository {
  Future<void> createPurchaseOrder(CreatePoParams params);
}
