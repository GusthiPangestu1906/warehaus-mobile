import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/entities/carrier.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class GetCarriers {
  final PurchaseOrderRepository repository;

  GetCarriers(this.repository);

  Future<Either<Failure, List<Carrier>>> call() async {
    return await repository.getCarriers();
  }
}
