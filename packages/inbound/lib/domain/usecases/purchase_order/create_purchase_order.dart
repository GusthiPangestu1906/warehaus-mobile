import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class CreatePurchaseOrder {
  final PurchaseOrderRepository repository;
  const CreatePurchaseOrder(this.repository);

  Future<Either<Failure, void>> call(CreatePoParams params) {
    return repository.createPurchaseOrder(params);
  }
}
