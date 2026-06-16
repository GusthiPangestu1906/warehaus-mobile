import 'package:product/data/datasources/product_api_datasource.dart';
import 'package:product/data/models/product_model.dart';
import 'package:product/domain/entities/product.dart';
import 'package:product/domain/repositories/product_repository.dart';
import 'package:product/domain/entities/category.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApiDatasource apiDatasource;
  ProductRepositoryImpl(this.apiDatasource);

  @override
  Future<List<Product>> getProducts() async {
    return await apiDatasource.getProducts();
  }

  @override
  Future<List<Category>> getCategories() async {
    final models = await apiDatasource.getCategories();
    return models
        .map((m) => Category(id: m.id, name: m.name))
        .toList();
  }

  @override
  Future<Product> getProductDetails(String id) async {
    final product = await apiDatasource.getProductDetails(id);
    return product;
  }

  @override
  Future<void> createProduct(Product product) async {
    final model = product is ProductModel
        ? product
        : ProductModel(
            id: product.id,
            sku: product.sku,
            productName: product.productName,
            barcode: product.barcode,
            categoryId: product.categoryId,
            unitOfMeasure: product.unitOfMeasure,
          );
    await apiDatasource.createProduct(model);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final model = product is ProductModel
        ? product
        : ProductModel(
            id: product.id,
            sku: product.sku,
            productName: product.productName,
            barcode: product.barcode,
            categoryId: product.categoryId,
            unitOfMeasure: product.unitOfMeasure,
            currentStock: product.currentStock,
            stocks: product.stocks,
          );
    await apiDatasource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await apiDatasource.deleteProduct(id);
  }

  // @override
  // Future<void> addStockLocation(StockLocationInput input) async {
  //   final model = input is StockLocationInputModel
  //       ? input
  //       : StockLocationInputModel(
  //           productId: input.productId,
  //           shelfId: input.shelfId,
  //           quantity: input.quantity,
  //         );
  //   await apiDatasource.addStockLocation(model);
  // }

  // @override
  // Future<void> updateStockLocation(StockLocationInput input) async {
  //   final model = input is StockLocationInputModel
  //       ? input
  //       : StockLocationInputModel(
  //           productId: input.productId,
  //           shelfId: input.shelfId,
  //           quantity: input.quantity,
  //         );
  //   await apiDatasource.updateStockLocation(model);
  // }

  // @override
  // Future<void> moveStockLocation(MoveStockInput input) async {
  //   final model = input is MoveStockInputModel
  //       ? input
  //       : MoveStockInputModel(
  //           productId: input.productId,
  //           fromShelfId: input.fromShelfId,
  //           toShelfId: input.toShelfId,
  //           quantity: input.quantity,
  //         );
  //   await apiDatasource.moveStockLocation(model);
  // }

  // @override
  // Future<void> deleteProductStockLocation({required String productId, required int shelfId}) async {
  //   await apiDatasource.deleteProductStockLocation(productId: productId, shelfId: shelfId);
  // }
}
