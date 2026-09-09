import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/entities/form/region.dart';
import 'package:outbound/domain/repositories/form_repository.dart';

class GetDistricts {
  final FormRepository repository;
  GetDistricts(this.repository);

  Future<Either<Failure, List<Region>>> call(String cityCode) {
    return repository.getDistricts(cityCode);
  }
}
