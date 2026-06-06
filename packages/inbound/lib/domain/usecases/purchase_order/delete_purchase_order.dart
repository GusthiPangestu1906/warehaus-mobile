import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class DeletePurchaseOrder {
  final PurchaseOrderRepository repository;

  DeletePurchaseOrder(this.repository);

  Future<void> call(int id) async {
    await repository.deletePurchaseOrder(id);
  }
}
