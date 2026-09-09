import 'package:core_services/helpers/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/repositories/form_repository.dart';
import 'package:outbound/domain/entities/form/courier.dart';
import 'package:outbound/domain/entities/form/region.dart';
import 'package:product/product.dart';
import 'package:outbound/data/datasources/form_api_datasource.dart';

class FormRepositoryImpl with RepositoryHelper implements FormRepository {
  final FormApiDatasource datasource;

  FormRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, List<Product>>> getProducts() {
    return execute(() => datasource.getProducts());
  }

  @override
  Future<Either<Failure, List<Courier>>> getCouriers() {
    return execute(() => datasource.getCouriers());
  }

  @override
  Future<Either<Failure, List<Region>>> getProvinces() {
    return execute(() => datasource.getProvinces());
  }

  @override
  Future<Either<Failure, List<Region>>> getCities(String provinceCode) {
    return execute(() => datasource.getCities(provinceCode));
  }

  @override
  Future<Either<Failure, List<Region>>> getDistricts(String cityCode) {
    return execute(() => datasource.getDistricts(cityCode));
  }
}
