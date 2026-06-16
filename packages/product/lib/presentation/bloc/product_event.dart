abstract class ProductEvent {}

class GetProductsEvent extends ProductEvent {}

class LoadCategoriesEvent extends ProductEvent {}

class GetProductDetailsEvent extends ProductEvent {
  final String id;

  GetProductDetailsEvent(this.id);
}

class CreateProductEvent extends ProductEvent {
  final String sku;
  final String productName;
  final String barcode;
  final String unitOfMeasure;
  final int? categoryId;

  CreateProductEvent({
    required this.sku,
    required this.productName,
    required this.barcode,
    required this.unitOfMeasure,
    this.categoryId,
  });
}

class UpdateProductEvent extends ProductEvent {
  final String id;
  final String? sku;
  final String? productName;
  final String? barcode;
  final String? unitOfMeasure;
  final int? categoryId;

  UpdateProductEvent({
    required this.id,
    this.sku,
    this.productName,
    this.barcode,
    this.unitOfMeasure,
    this.categoryId,
  });
}

class DeleteProductEvent extends ProductEvent {
  final String id;

  DeleteProductEvent(this.id);
}

class AddStockLocationEvent extends ProductEvent {
  final String productId;
  final int shelfId;
  final int quantity;

  AddStockLocationEvent({
    required this.productId,
    required this.shelfId,
    required this.quantity,
  });
}

class UpdateStockLocationEvent extends ProductEvent {
  final String productId;
  final int shelfId;
  final int quantity;

  UpdateStockLocationEvent({
    required this.productId,
    required this.shelfId,
    required this.quantity,
  });
}

class MoveStockLocationEvent extends ProductEvent {
  final String productId;
  final int fromShelfId;
  final int toShelfId;
  final int quantity;

  MoveStockLocationEvent({
    required this.productId,
    required this.fromShelfId,
    required this.toShelfId,
    required this.quantity,
  });
}

class DeleteProductStockLocationEvent extends ProductEvent {
  final String productId;
  final int shelfId;

  DeleteProductStockLocationEvent({
    required this.productId,
    required this.shelfId,
  });
}
