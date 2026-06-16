import 'package:dio/dio.dart';
import 'package:product/data/models/category_model.dart';
import 'package:product/data/models/product_model.dart';

class ProductApiDatasource {
  final Dio dio;
  ProductApiDatasource(this.dio);

  static const String _productPath = '/Products';
  static const String _stockLocationsPath = '/product/stock-locations';
  static const String _categoriesPath = '/categories';

  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get(_productPath);
    return (response.data as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get(_categoriesPath);
    return (response.data as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> getProductDetails(String id) async {
    final response = await dio.get('$_productPath/$id');
    return ProductModel.fromJson(response.data);
  }

  Future<void> createProduct(ProductModel product) async {
    await dio.post(_productPath, data: product.toJson());
  }

  Future<void> updateProduct(ProductModel product) async {
    await dio.put('$_productPath/${product.id}', data: product.toJson());
  }

  Future<void> deleteProduct(String id) async {
    await dio.delete('$_productPath/$id');
  }
}
