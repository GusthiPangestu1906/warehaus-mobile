class ShelfDetail {
  final int id;
  final String shelfCode;
  final int aisle;
  final int capacity;
  final int currentVolume;
  final String qrCodePath;
  final List<ShelfStock> stocks;

  ShelfDetail({
    required this.id,
    required this.shelfCode,
    required this.aisle,
    required this.capacity,
    required this.currentVolume,
    required this.qrCodePath,
    required this.stocks,
  });

  factory ShelfDetail.fromJson(Map<String, dynamic> json) {
    return ShelfDetail(
      id: json['id'] as int? ?? 0,
      shelfCode: json['shelfCode'] as String? ?? '',
      aisle: json['aisle'] as int? ?? 0,
      capacity: json['capacity'] as int? ?? 0,
      currentVolume: json['currentVolume'] as int? ?? 0,
      qrCodePath: json['qrCodePath'] as String? ?? '',
      stocks:
          (json['stocks'] as List<dynamic>?)
              ?.map((e) => ShelfStock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ShelfStock {
  final int id;
  final int shelfId;
  final int productId;
  final int quantity;
  final ShelfProduct product;

  ShelfStock({
    required this.id,
    required this.shelfId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  factory ShelfStock.fromJson(Map<String, dynamic> json) {
    return ShelfStock(
      id: json['id'] as int? ?? 0,
      shelfId: json['shelfId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      product: ShelfProduct.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ShelfProduct {
  final int id;
  final String sku;
  final String productName;
  final String barcode;
  final String unitOfMeasure;
  final int currentStock;

  ShelfProduct({
    required this.id,
    required this.sku,
    required this.productName,
    required this.barcode,
    required this.unitOfMeasure,
    required this.currentStock,
  });

  factory ShelfProduct.fromJson(Map<String, dynamic> json) {
    return ShelfProduct(
      id: json['id'] as int? ?? 0,
      sku: json['sku'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      unitOfMeasure: json['unitOfMeasure'] as String? ?? '',
      currentStock: json['currentStock'] as int? ?? 0,
    );
  }
}
