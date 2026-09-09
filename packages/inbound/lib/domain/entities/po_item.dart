import 'package:equatable/equatable.dart';

class PoItem extends Equatable {
  final int id;
  final int productId;
  final int qtyExpected;
  final int qtyReceived;
  final bool isQcCompleted;
  final String? productCode;
  final String? productName;
  final String? sku;
  final String? qcStatus;
  final PoProductDetail? productDetail;

  const PoItem({
    required this.id,
    required this.productId,
    required this.qtyExpected,
    required this.qtyReceived,
    this.isQcCompleted = false,
    this.productCode,
    this.productName,
    this.sku,
    this.qcStatus,
    this.productDetail,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    qtyExpected,
    qtyReceived,
    isQcCompleted,
    productCode,
    productName,
    sku,
    qcStatus,
    productDetail,
  ];
}

class PoProductDetail extends Equatable {
  const PoProductDetail({
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
