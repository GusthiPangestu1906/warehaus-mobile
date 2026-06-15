class SoItemModel {
  final int? id;
  final int productId;
  final int qtyOrdered;
  final String? productName;
  final String? sku;
  final String? barcode;
  final String? unitOfMeasure;
  final int qtyPicked;
  final int qtyVerified;
  final List<SoItemSuggestedLocationModel> suggestedLocations;

  const SoItemModel({
    this.id,
    required this.productId,
    required this.qtyOrdered,
    this.productName,
    this.sku,
    this.barcode,
    this.unitOfMeasure,
    this.qtyPicked = 0,
    this.qtyVerified = 0,
    this.suggestedLocations = const [],
  });

  factory SoItemModel.fromJson(Map<String, dynamic> json) {
    return SoItemModel(
      id: json['id'] == null ? null : _asInt(json['id']),
      productId: _asInt(json['productId']),
      qtyOrdered: _asInt(json['qtyOrdered']),
      productName: json['productName']?.toString(),
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      unitOfMeasure: json['unitOfMeasure']?.toString(),
      qtyPicked: _asInt(json['qtyPicked']),
      qtyVerified: _asInt(json['qtyVerified']),
      suggestedLocations:
          (json['suggestedLocations'] as List<dynamic>?)
              ?.map(
                (location) => SoItemSuggestedLocationModel.fromJson(
                  location as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'qtyOrdered': qtyOrdered};
  }
}

class SoItemSuggestedLocationModel {
  final int shelfId;
  final String shelfCode;
  final String zoneCode;
  final String zoneName;
  final int aisle;
  final int availableQuantity;

  const SoItemSuggestedLocationModel({
    required this.shelfId,
    required this.shelfCode,
    required this.zoneCode,
    required this.zoneName,
    required this.aisle,
    required this.availableQuantity,
  });

  factory SoItemSuggestedLocationModel.fromJson(Map<String, dynamic> json) {
    return SoItemSuggestedLocationModel(
      shelfId: _asInt(json['shelfId']),
      shelfCode: json['shelfCode']?.toString() ?? '',
      zoneCode: json['zoneCode']?.toString() ?? '',
      zoneName: json['zoneName']?.toString() ?? '',
      aisle: _asInt(json['aisle']),
      availableQuantity: _asInt(json['availableQuantity']),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
