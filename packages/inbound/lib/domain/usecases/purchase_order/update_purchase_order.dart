import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class UpdatePurchaseOrder {
  const UpdatePurchaseOrder(this.repository);

  final PurchaseOrderRepository repository;

  Future<Either<Failure, void>> call(int id, CreatePoParams params) {
    return repository.updatePurchaseOrder(id, params);
  }
}
