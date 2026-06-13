import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/entities/qc_next_item.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class GetQcNextItem {
  const GetQcNextItem(this.repository);

  final PurchaseOrderRepository repository;

  Future<Either<Failure, QcNextItem>> call(int poId) {
    return repository.getQcNextItem(poId);
  }
}
