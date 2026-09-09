import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/entities/form/region.dart';
import 'package:outbound/domain/repositories/form_repository.dart';

class GetProvinces {
  final FormRepository repository;
  GetProvinces(this.repository);

  Future<Either<Failure, List<Region>>> call() {
    return repository.getProvinces();
  }
}
