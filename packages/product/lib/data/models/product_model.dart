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
    super.categoryName,
    required super.unitOfMeasure,
    super.currentStock,
    List<Stock>? stocks,
  }) : super(stocks: stocks ?? []);

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      sku: (json['sku'] ?? json['SKU'])?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      categoryId: json['categoryId'],
      categoryName:
          (json['categoryName'] ??
                  json['category_name'] ??
                  json['category']?['name'])
              ?.toString() ??
          '',
      unitOfMeasure: json['unitOfMeasure']?.toString() ?? '',
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
    'categoryId': categoryId ?? 0,
  };
}
