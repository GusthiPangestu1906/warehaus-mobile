import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/entities/form/courier.dart';
import 'package:outbound/domain/repositories/form_repository.dart';

class GetCouriers {
  final FormRepository repository;
  GetCouriers(this.repository);

  Future<Either<Failure, List<Courier>>> call() {
    return repository.getCouriers();
  }
}
