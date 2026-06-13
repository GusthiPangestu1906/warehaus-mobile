import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class SubmitPa {
  const SubmitPa(this.repository);

  final PurchaseOrderRepository repository;

  Future<Either<Failure, void>> call(
    SubmitPaParams params,
    int receivingLogId,
  ) {
    return repository.submitPa(params, receivingLogId);
  }
}
