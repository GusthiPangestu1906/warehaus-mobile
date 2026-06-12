class SoItemModel {
  final int productId;
  final int qtyOrdered;
  final String? productName;
  final String? sku;
  final String? barcode;
  final String? unitOfMeasure;
  final int qtyPicked;
  final int qtyVerified;

  const SoItemModel({
    required this.productId,
    required this.qtyOrdered,
    this.productName,
    this.sku,
    this.barcode,
    this.unitOfMeasure,
    this.qtyPicked = 0,
    this.qtyVerified = 0,
  });

  factory SoItemModel.fromJson(Map<String, dynamic> json) {
    return SoItemModel(
      productId: _asInt(json['productId']),
      qtyOrdered: _asInt(json['qtyOrdered']),
      productName: json['productName'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      unitOfMeasure: json['unitOfMeasure'] as String?,
      qtyPicked: _asInt(json['qtyPicked']),
      qtyVerified: _asInt(json['qtyVerified']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'qtyOrdered': qtyOrdered};
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
