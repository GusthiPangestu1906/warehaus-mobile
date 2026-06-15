import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class GetPurchaseOrderDetail {
  final PurchaseOrderRepository repository;

  GetPurchaseOrderDetail(this.repository);

  Future<Either<Failure, PurchaseOrder>> call(int id) async {
    return await repository.getPurchaseOrderDetail(id);
  }
}
