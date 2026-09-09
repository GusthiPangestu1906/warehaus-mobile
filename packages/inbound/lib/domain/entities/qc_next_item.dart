import 'package:equatable/equatable.dart';

class QcNextItem extends Equatable {
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

  @override
  List<Object?> get props => [
    id,
    productId,
    sku,
    productName,
    qtyExpected,
    qtyReceived,
    currentItemNumber,
    totalItems,
    productDetail,
    nextItem,
  ];
}

class QcProductDetail extends Equatable {
  final int id;
  final String sku;
  final String productName;
  final String barcode;
  final String unitOfMeasure;
  final int categoryId;

  const QcProductDetail({
    required this.id,
    required this.sku,
    required this.productName,
    required this.barcode,
    required this.unitOfMeasure,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [
    id,
    sku,
    productName,
    barcode,
    unitOfMeasure,
    categoryId,
  ];
}

class QcUpcomingItem extends Equatable {
  final int id;
  final String sku;
  final String productName;
  final int qtyExpected;
  final String unitOfMeasure;

  const QcUpcomingItem({
    required this.id,
    required this.sku,
    required this.productName,
    required this.qtyExpected,
    required this.unitOfMeasure,
  });

  @override
  List<Object?> get props => [id, sku, productName, qtyExpected, unitOfMeasure];
}
