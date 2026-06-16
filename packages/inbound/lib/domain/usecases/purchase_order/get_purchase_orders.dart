import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class GetPurchaseOrders {
  final PurchaseOrderRepository repository;
  GetPurchaseOrders(this.repository);

  Future<Either<Failure, List<PurchaseOrder>>> call({DateTime? date}) async {
    return await repository.getPurchaseOrders(date?.toUtc());
  }
}
