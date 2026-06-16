import 'package:product/domain/entities/category.dart';
import 'package:product/domain/repositories/product_repository.dart';

class GetCategories {
  final ProductRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() {
    return repository.getCategories();
  }
}