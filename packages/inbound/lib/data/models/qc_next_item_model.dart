import 'package:inbound/domain/entities/qc_next_item.dart';

class QcNextItemModel extends QcNextItem {
  const QcNextItemModel({
    required super.id,
    required super.productId,
    required super.sku,
    required super.productName,
    required super.qtyExpected,
    required super.qtyReceived,
    required super.currentItemNumber,
    required super.totalItems,
    required QcProductDetailModel super.productDetail,
    QcUpcomingItemModel? super.nextItem,
  });

  factory QcNextItemModel.fromJson(Map<String, dynamic> json) {
    return QcNextItemModel(
      id: json['id'],
      productId: json['productId'],
      sku: json['sku'],
      productName: json['productName'],
      qtyExpected: json['qtyExpected'],
      qtyReceived: json['qtyReceived'],
      currentItemNumber: json['currentItemNumber'],
      totalItems: json['totalItems'],
      productDetail: QcProductDetailModel.fromJson(
        json['productDetail'] as Map<String, dynamic>,
      ),
      nextItem: json['nextItem'] == null
          ? null
          : QcUpcomingItemModel.fromJson(
              json['nextItem'] as Map<String, dynamic>,
            ),
    );
  }
}

class QcProductDetailModel extends QcProductDetail {
  const QcProductDetailModel({
    required super.id,
    required super.sku,
    required super.productName,
    required super.barcode,
    required super.unitOfMeasure,
    required super.categoryId,
  });

  factory QcProductDetailModel.fromJson(Map<String, dynamic> json) {
    return QcProductDetailModel(
      id: json['id'],
      sku: json['sku'],
      productName: json['productName'],
      barcode: json['barcode'],
      unitOfMeasure: json['unitOfMeasure'],
      categoryId: json['categoryId'],
    );
  }
}

class QcUpcomingItemModel extends QcUpcomingItem {
  const QcUpcomingItemModel({
    required super.id,
    required super.sku,
    required super.productName,
    required super.qtyExpected,
    required super.unitOfMeasure,
  });

  factory QcUpcomingItemModel.fromJson(Map<String, dynamic> json) {
    return QcUpcomingItemModel(
      id: json['id'],
      sku: json['sku'],
      productName: json['productName'],
      qtyExpected: json['qtyExpected'],
      unitOfMeasure: json['unitOfMeasure'],
    );
  }
}
