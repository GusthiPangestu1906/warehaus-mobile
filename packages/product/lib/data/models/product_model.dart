import 'package:product/data/models/stock_model.dart';
import 'package:product/domain/entities/product.dart';
import 'package:product/domain/entities/stock.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.sku,
    required super.productName,
    required super.barcode,
    required super.categoryId,
    required super.unitOfMeasure,
    super.currentStock,
    List<Stock>? stocks,
  }) : super(
         stocks: stocks ?? [],
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      sku: (json['sku'] ?? json['SKU']) as String? ?? '',
      productName: json['productName'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      categoryId: json['categoryId'],
      unitOfMeasure: json['unitOfMeasure'] as String? ?? '',
      currentStock: json['currentStock'] as int? ?? 0,
      stocks: (json['stock'] ?? json['stocks']) != null
          ? ((json['stock'] ?? json['stocks']) as List)
                .map(
                  (stock) => StockModel.fromJson(stock as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': int.tryParse(id) ?? 0,
    'sku': sku,
    'productName': productName,
    'barcode': barcode,
    'unitOfMeasure': unitOfMeasure,
    'stocks': stocks?.map((stock) => (stock as StockModel).toJson()).toList(),
    'categoryId': int ?? 0,
  };
}
