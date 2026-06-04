import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/domain/params/create_po_params.dart';

abstract class PurchaseOrderRepository {
  Future<List<PurchaseOrder>> getPurchaseOrders();
  Future<PurchaseOrder> getPurchaseOrderDetail(int id);
  Future<void> createPurchaseOrder(CreatePoParams params);
}
