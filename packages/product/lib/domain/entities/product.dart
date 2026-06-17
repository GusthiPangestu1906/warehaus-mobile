import 'stock.dart';

class Product {
  final String id;
  final String sku;
  final String productName;
  final String barcode;
  final int? categoryId;
  final String unitOfMeasure;
  final int currentStock;
  final List<Stock>? stocks;

  Product({
    required this.id,
    required this.sku,
    required this.productName,
    required this.barcode,
    this.categoryId,
    required this.unitOfMeasure,
    this.currentStock = 0,
    this.stocks,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      sku: (json['sku'] ?? json['SKU'])?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      categoryId: json['categoryId'],
      unitOfMeasure: json['unitOfMeasure']?.toString() ?? '',
      currentStock: json['currentStock'] as int? ?? 0,
      stocks: (json['stock'] ?? json['stocks']) != null
          ? ((json['stock'] ?? json['stocks']) as List)
                .map((stock) => Stock.fromJson(stock as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}
