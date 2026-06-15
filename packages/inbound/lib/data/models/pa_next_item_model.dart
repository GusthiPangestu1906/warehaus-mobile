import 'package:inbound/domain/entities/pa_next_item.dart'; // Sesuaikan path entity Anda

class PaNextItemModel extends PaNextItem {
  const PaNextItemModel({
    required super.receivingLogId,
    required super.poItemId,
    required super.poNumber,
    required super.sku,
    required super.productName,
    required super.qtyExpected,
    required super.qtyReceived,
    required super.condition,
    required super.unitOfMeasure,
    required super.currentItemNumber,
    required super.totalItems,
    required super.isLastItem,
    super.completedShelves,
    required List<RecommendedShelfModel> super.recommendedShelves,
    PaUpcomingItemModel? super.upcoming,
  });

  factory PaNextItemModel.fromJson(Map<String, dynamic> json) {
    return PaNextItemModel(
      receivingLogId: json['receivingLogId'],
      poItemId: json['poItemId'],
      poNumber: json['poNumber'],
      sku: json['sku'],
      productName: json['productName'],
      qtyExpected: json['qtyExpected'],
      qtyReceived: json['qtyReceived'],
      condition: json['condition'],
      unitOfMeasure: json['unitOfMeasure'],
      currentItemNumber: json['currentItemNumber'],
      totalItems: json['totalItems'],
      isLastItem: json['isLastItem'],
      completedShelves: json['completedShelves'] as List<dynamic>?,
      recommendedShelves: json['recommendedShelves'] != null
          ? List<RecommendedShelfModel>.from(
              (json['recommendedShelves'] as List).map(
                (x) =>
                    RecommendedShelfModel.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      upcoming: json['upcoming'] == null
          ? null
          : PaUpcomingItemModel.fromJson(
              json['upcoming'] as Map<String, dynamic>,
            ),
    );
  }
}

class RecommendedShelfModel extends RecommendedShelf {
  const RecommendedShelfModel({
    required super.shelfId,
    required super.shelfCode,
    required super.zoneName,
    required super.zoneCode,
    required super.categoryName,
    required super.aisle,
    required super.shelfNumber,
    required super.availableCapacity,
    required super.locationText,
    required super.displayName,
    required super.qtyRequired,
    super.isCompleted,
  });

  factory RecommendedShelfModel.fromJson(Map<String, dynamic> json) {
    return RecommendedShelfModel(
      shelfId: json['shelfId'],
      shelfCode: json['shelfCode'],
      zoneName: json['zoneName'],
      zoneCode: json['zoneCode'],
      categoryName: json['categoryName'],
      aisle: json['aisle'],
      shelfNumber: json['shelfNumber'],
      availableCapacity: json['availableCapacity'],
      locationText: json['locationText'],
      displayName: json['displayName'],
      qtyRequired: json['qtyRequired'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class PaUpcomingItemModel extends PaUpcomingItem {
  const PaUpcomingItemModel({
    required super.id,
    required super.sku,
    required super.productName,
    required super.qtyExpected,
    required super.unitOfMeasure,
  });

  factory PaUpcomingItemModel.fromJson(Map<String, dynamic> json) {
    return PaUpcomingItemModel(
      id: json['id'],
      sku: json['sku'],
      productName: json['productName'],
      qtyExpected: json['qtyExpected'],
      unitOfMeasure: json['unitOfMeasure'],
    );
  }
}
