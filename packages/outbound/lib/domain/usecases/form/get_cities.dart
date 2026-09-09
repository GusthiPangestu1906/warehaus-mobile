import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/repositories/form_repository.dart';
import 'package:outbound/domain/entities/form/region.dart';

class GetCities {
  final FormRepository repository;
  GetCities(this.repository);

  Future<Either<Failure, List<Region>>> call(String provinceCode) {
    return repository.getCities(provinceCode);
  }
}
