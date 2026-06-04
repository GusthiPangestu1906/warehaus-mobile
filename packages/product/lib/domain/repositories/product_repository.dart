import 'package:product/domain/entities/product.dart';
// import 'package:product/domain/entities/stock_location_input.dart'; // TODO: /v1/product/stock-locations belum ada di backend
// import 'package:product/data/models/stock_location_input_model.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductDetails(String id);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);

  // TODO: /v1/product/stock-locations belum ada di backend
  // Future<void> addStockLocation(StockLocationInput input);
  // Future<void> updateStockLocation(StockLocationInput input);
  // Future<void> moveStockLocation(MoveStockInput input);
  // Future<void> deleteProductStockLocation({required String productId, required int shelfId});
}