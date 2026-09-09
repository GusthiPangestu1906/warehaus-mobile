import 'package:equatable/equatable.dart';

class SoItem extends Equatable {
  final int? id;
  final int productId;
  final int qtyOrdered;
  final String? productName;
  final String? sku;
  final String? barcode;
  final String? unitOfMeasure;
  final int qtyPicked;
  final int qtyVerified;
  final List<SoItemSuggestedLocation> suggestedLocations;

  const SoItem({
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

  @override
  List<Object?> get props => [
    id,
    productId,
    qtyOrdered,
    productName,
    sku,
    barcode,
    unitOfMeasure,
    qtyPicked,
    qtyVerified,
    suggestedLocations,
  ];
}

class SoItemSuggestedLocation extends Equatable {
  final int shelfId;
  final String shelfCode;
  final String zoneCode;
  final String zoneName;
  final int aisle;
  final int availableQuantity;

  const SoItemSuggestedLocation({
    required this.shelfId,
    required this.shelfCode,
    required this.zoneCode,
    required this.zoneName,
    required this.aisle,
    required this.availableQuantity,
  });

  @override
  List<Object?> get props => [
    shelfId,
    shelfCode,
    zoneCode,
    zoneName,
    aisle,
    availableQuantity,
  ];
}
