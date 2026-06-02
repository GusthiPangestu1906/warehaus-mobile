import 'package:dio/dio.dart';
import 'package:product/data/models/product_model.dart';
import 'package:product/data/models/stock_location_input_model.dart';

class ProductApiDatasource {
  final Dio dio;
  ProductApiDatasource(this.dio);

  static const String _productPath = '/v1/Product';
  static const String _stockLocationsPath = '/v1/product/stock-locations';

  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get(_productPath);
    return (response.data as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
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

  Future<void> addStockLocation(StockLocationInputModel input) async {
    await dio.post(_stockLocationsPath, data: input.toJson());
  }

  Future<void> updateStockLocation(StockLocationInputModel input) async {
    await dio.put(_stockLocationsPath, data: input.toJson());
  }

  Future<void> moveStockLocation(MoveStockInputModel input) async {
    await dio.post('$_stockLocationsPath/move', data: input.toJson());
  }

  Future<void> deleteProductStockLocation({
    required String productId,
    required int shelfId,
  }) async {
    await dio.delete(
      _stockLocationsPath,
      data: {'productId': productId, 'shelfId': shelfId},
    );
  }
}
