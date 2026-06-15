import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/entities/pa_next_item.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class GetPaNextItem {
  final PurchaseOrderRepository repository;

  GetPaNextItem(this.repository);

  Future<Either<Failure, PaNextItem>> call(int poId) async {
    return await repository.getPaNextItem(poId);
  }
}
