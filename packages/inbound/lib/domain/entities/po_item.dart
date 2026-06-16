class PoItem {
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

  PoItem copyWith({
    int? id,
    int? productId,
    int? qtyExpected,
    int? qtyReceived,
    bool? isQcCompleted,
    String? productCode,
    String? productName,
    String? sku,
    String? qcStatus,
    PoProductDetail? productDetail,
  }) {
    return PoItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      qtyExpected: qtyExpected ?? this.qtyExpected,
      qtyReceived: qtyReceived ?? this.qtyReceived,
      isQcCompleted: isQcCompleted ?? this.isQcCompleted,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      qcStatus: qcStatus ?? this.qcStatus,
      productDetail: productDetail ?? this.productDetail,
    );
  }
}

class PoProductDetail {
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
}
