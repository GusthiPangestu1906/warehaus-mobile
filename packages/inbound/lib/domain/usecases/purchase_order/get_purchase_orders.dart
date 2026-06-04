import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class GetPurchaseOrders {
  final PurchaseOrderRepository repository;
  GetPurchaseOrders(this.repository);

  Future<List<PurchaseOrder>> call() async {
    return await repository.getPurchaseOrders();
  }
}
