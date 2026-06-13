import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/params/submit_qc_params.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class SubmitQc {
  const SubmitQc(this.repository);

  final PurchaseOrderRepository repository;

  Future<Either<Failure, void>> call(SubmitQcParams params) {
    return repository.submitQc(params);
  }
}
