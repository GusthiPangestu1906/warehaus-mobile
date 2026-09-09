import 'package:outbound/domain/entities/so_item.dart';

class SoItemModel extends SoItem {
  const SoItemModel({
    super.id,
    required super.productId,
    required super.qtyOrdered,
    super.productName,
    super.sku,
    super.barcode,
    super.unitOfMeasure,
    super.qtyPicked,
    super.qtyVerified,
    super.suggestedLocations,
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
    return {
      "id": id,
      "productId": productId,
      "qtyOrdered": qtyOrdered,
      "productName": productName,
      "sku": sku,
      "barcode": barcode,
      "unitOfMeasure": unitOfMeasure,
      "qtyPicked": qtyPicked,
      "qtyVerified": qtyVerified,
      "suggestedLocations": suggestedLocations,
    };
  }

  factory SoItemModel.fromEntity(SoItem entity) {
    return SoItemModel(
      id: entity.id,
      productId: entity.productId,
      qtyOrdered: entity.qtyOrdered,
      productName: entity.productName,
      sku: entity.sku,
      barcode: entity.barcode,
      unitOfMeasure: entity.unitOfMeasure,
      qtyPicked: entity.qtyPicked,
      qtyVerified: entity.qtyVerified,
      suggestedLocations: entity.suggestedLocations
          .map((location) => SoItemSuggestedLocationModel.fromEntity(location))
          .toList(),
    );
  }
}

extension SoItemModelMapper on SoItemModel {
  SoItem toEntity() {
    return SoItem(
      id: id,
      productId: productId,
      qtyOrdered: qtyOrdered,
      productName: productName,
      sku: sku,
      barcode: barcode,
      unitOfMeasure: unitOfMeasure,
      qtyPicked: qtyPicked,
      qtyVerified: qtyVerified,
      suggestedLocations: suggestedLocations
          .map(
            (location) => (location as SoItemSuggestedLocationModel).toEntity(),
          )
          .toList(),
    );
  }
}

class SoItemSuggestedLocationModel extends SoItemSuggestedLocation {
  const SoItemSuggestedLocationModel({
    required super.shelfId,
    required super.shelfCode,
    required super.zoneCode,
    required super.zoneName,
    required super.aisle,
    required super.availableQuantity,
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

  factory SoItemSuggestedLocationModel.fromEntity(
    SoItemSuggestedLocation entity,
  ) {
    return SoItemSuggestedLocationModel(
      shelfId: entity.shelfId,
      shelfCode: entity.shelfCode,
      zoneCode: entity.zoneCode,
      zoneName: entity.zoneName,
      aisle: entity.aisle,
      availableQuantity: entity.availableQuantity,
    );
  }

  SoItemSuggestedLocation toEntity() {
    return SoItemSuggestedLocation(
      shelfId: shelfId,
      shelfCode: shelfCode,
      zoneCode: zoneCode,
      zoneName: zoneName,
      aisle: aisle,
      availableQuantity: availableQuantity,
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
