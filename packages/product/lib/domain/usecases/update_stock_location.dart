// import 'package:product/domain/entities/stock_location_input.dart'; // TODO: /v1/product/stock-locations belum ada di backend
import 'package:product/domain/repositories/product_repository.dart';

class UpdateStockLocation {
  final ProductRepository repository;

  const UpdateStockLocation(this.repository);

  // Future<void> call(StockLocationInput input) {
  //   return repository.updateStockLocation(input);
  // }
}