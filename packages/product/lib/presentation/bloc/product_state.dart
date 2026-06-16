import 'package:product/domain/entities/product.dart';
import 'package:product/domain/entities/category.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded(this.products);
}

class ProductDetailLoaded extends ProductState {
  final Product product;
  ProductDetailLoaded(this.product);
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

class ProductActionSuccess extends ProductState {
  final String action;
  ProductActionSuccess(this.action);
}

class CategoriesLoading extends ProductState {}

class CategoriesLoaded extends ProductState {
  final List<Category> categories;
  CategoriesLoaded(this.categories);
}
class CategoriesError extends ProductState {
  final String message;
  CategoriesError(this.message);
}
