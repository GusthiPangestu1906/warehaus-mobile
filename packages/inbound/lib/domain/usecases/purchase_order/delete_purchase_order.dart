import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class DeletePurchaseOrder {
  final PurchaseOrderRepository repository;

  DeletePurchaseOrder(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deletePurchaseOrder(id);
  }
}
