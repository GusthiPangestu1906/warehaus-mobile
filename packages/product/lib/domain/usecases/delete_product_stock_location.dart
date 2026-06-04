import 'package:product/domain/repositories/product_repository.dart';

class DeleteProductStockLocation {
  final ProductRepository repository;
  DeleteProductStockLocation(this.repository);

  // Future<void> call({required String productId, required int shelfId}) {
  //   return repository.deleteProductStockLocation(
  //     productId: productId,
  //     shelfId: shelfId,
  //   );
  // }
}