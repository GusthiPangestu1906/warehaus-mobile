class PaNextItem {
  final int receivingLogId;
  final int poItemId;
  final String poNumber;
  final String sku;
  final String productName;
  final int qtyExpected;
  final int qtyReceived;
  final String condition;
  final String unitOfMeasure;
  final int currentItemNumber;
  final int totalItems;
  final bool isLastItem;
  final List<dynamic>? completedShelves;
  final List<RecommendedShelf> recommendedShelves;
  final PaUpcomingItem? upcoming;

  const PaNextItem({
    required this.receivingLogId,
    required this.poItemId,
    required this.poNumber,
    required this.sku,
    required this.productName,
    required this.qtyExpected,
    required this.qtyReceived,
    required this.condition,
    required this.unitOfMeasure,
    required this.currentItemNumber,
    required this.totalItems,
    required this.isLastItem,
    this.completedShelves,
    required this.recommendedShelves,
    this.upcoming,
  });
}

class RecommendedShelf {
  final int shelfId;
  final String shelfCode;
  final String zoneName;
  final String zoneCode;
  final String categoryName;
  final int aisle;
  final int shelfNumber;
  final int availableCapacity;
  final String locationText;
  final String displayName;
  final int qtyRequired;
  final bool isCompleted;

  const RecommendedShelf({
    required this.shelfId,
    required this.shelfCode,
    required this.zoneName,
    required this.zoneCode,
    required this.categoryName,
    required this.aisle,
    required this.shelfNumber,
    required this.availableCapacity,
    required this.locationText,
    required this.displayName,
    required this.qtyRequired,
    this.isCompleted = false,
  });
}

class PaUpcomingItem {
  const PaUpcomingItem({
    required this.id,
    required this.sku,
    required this.productName,
    required this.qtyExpected,
    required this.unitOfMeasure,
  });

  final int id;
  final String sku;
  final String productName;
  final int qtyExpected;
  final String unitOfMeasure;
}
