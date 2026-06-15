class QcNextItem {
  const QcNextItem({
    required this.id,
    required this.productId,
    required this.sku,
    required this.productName,
    required this.qtyExpected,
    required this.qtyReceived,
    required this.currentItemNumber,
    required this.totalItems,
    required this.productDetail,
    this.nextItem,
  });

  final int id;
  final int productId;
  final String sku;
  final String productName;
  final int qtyExpected;
  final int qtyReceived;
  final int currentItemNumber;
  final int totalItems;
  final QcProductDetail productDetail;
  final QcUpcomingItem? nextItem;
}

class QcProductDetail {
  const QcProductDetail({
    required this.id,
    required this.sku,
    required this.productName,
    required this.barcode,
    required this.unitOfMeasure,
    required this.categoryId,
  });

  final int id;
  final String sku;
  final String productName;
  final String barcode;
  final String unitOfMeasure;
  final int categoryId;
}

class QcUpcomingItem {
  const QcUpcomingItem({
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
