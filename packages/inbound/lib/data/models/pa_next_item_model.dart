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

  Map<String, dynamic> toJson() {
    return {
      'receivingLogId': receivingLogId,
      'poItemId': poItemId,
      'poNumber': poNumber,
      'sku': sku,
      'productName': productName,
      'qtyExpected': qtyExpected,
      'qtyReceived': qtyReceived,
      'condition': condition,
      'unitOfMeasure': unitOfMeasure,
      'currentItemNumber': currentItemNumber,
      'totalItems': totalItems,
      'isLastItem': isLastItem,
      'completedShelves': completedShelves,
      'recommendedShelves': recommendedShelves,
      'upcoming': upcoming,
    };
  }

  factory PaNextItemModel.fromEntity(PaNextItem entity) {
    return PaNextItemModel(
      receivingLogId: entity.receivingLogId,
      poItemId: entity.poItemId,
      poNumber: entity.poNumber,
      sku: entity.sku,
      productName: entity.productName,
      qtyExpected: entity.qtyExpected,
      qtyReceived: entity.qtyReceived,
      condition: entity.condition,
      unitOfMeasure: entity.unitOfMeasure,
      currentItemNumber: entity.currentItemNumber,
      totalItems: entity.totalItems,
      isLastItem: entity.isLastItem,
      completedShelves: entity.completedShelves,
      recommendedShelves: entity.recommendedShelves
          .map((e) => RecommendedShelfModel.fromEntity(e))
          .toList(),
      upcoming: entity.upcoming != null
          ? PaUpcomingItemModel.fromEntity(entity.upcoming!)
          : null,
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

  Map<String, dynamic> toJson() {
    return {
      'shelfId': shelfId,
      'shelfCode': shelfCode,
      'zoneName': zoneName,
      'zoneCode': zoneCode,
      'categoryName': categoryName,
      'aisle': aisle,
      'shelfNumber': shelfNumber,
      'availableCapacity': availableCapacity,
      'locationText': locationText,
      'displayName': displayName,
      'qtyRequired': qtyRequired,
      'isCompleted': isCompleted,
    };
  }

  factory RecommendedShelfModel.fromEntity(RecommendedShelf entity) {
    return RecommendedShelfModel(
      shelfId: entity.shelfId,
      shelfCode: entity.shelfCode,
      zoneName: entity.zoneName,
      zoneCode: entity.zoneCode,
      categoryName: entity.categoryName,
      aisle: entity.aisle,
      shelfNumber: entity.shelfNumber,
      availableCapacity: entity.availableCapacity,
      locationText: entity.locationText,
      displayName: entity.displayName,
      qtyRequired: entity.qtyRequired,
      isCompleted: entity.isCompleted,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'qtyExpected': qtyExpected,
      'unitOfMeasure': unitOfMeasure,
    };
  }

  factory PaUpcomingItemModel.fromEntity(PaUpcomingItem entity) {
    return PaUpcomingItemModel(
      id: entity.id,
      sku: entity.sku,
      productName: entity.productName,
      qtyExpected: entity.qtyExpected,
      unitOfMeasure: entity.unitOfMeasure,
    );
  }
}
