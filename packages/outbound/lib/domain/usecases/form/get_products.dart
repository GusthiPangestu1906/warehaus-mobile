import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:product/product.dart';
import 'package:outbound/domain/repositories/form_repository.dart';

class GetProducts {
  final FormRepository repository;
  GetProducts(this.repository);

  Future<Either<Failure, List<Product>>> call() {
    return repository.getProducts();
  }
}
