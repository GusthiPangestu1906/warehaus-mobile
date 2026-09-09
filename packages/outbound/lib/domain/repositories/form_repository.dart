import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:product/product.dart';
import 'package:outbound/domain/entities/form/courier.dart';
import 'package:outbound/domain/entities/form/region.dart';

abstract class FormRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, List<Courier>>> getCouriers();
  Future<Either<Failure, List<Region>>> getProvinces();
  Future<Either<Failure, List<Region>>> getCities(String provinceCode);
  Future<Either<Failure, List<Region>>> getDistricts(String cityCode);
}
