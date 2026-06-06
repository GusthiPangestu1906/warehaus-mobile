class PoItem {
  final int id;
  final int productId;
  final int qtyExpected;
  final int qtyReceived;
  final String? productCode;
  final String? productName;
  final String? sku;
  final String? qcStatus;

  const PoItem({
    required this.id,
    required this.productId,
    required this.qtyExpected,
    required this.qtyReceived,
    this.productCode,
    this.productName,
    this.sku,
    this.qcStatus,
  });

  PoItem copyWith({
    int? id,
    int? productId,
    int? qtyExpected,
    int? qtyReceived,
    String? productCode,
    String? productName,
    String? sku,
    String? qcStatus,
  }) {
    return PoItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      qtyExpected: qtyExpected ?? this.qtyExpected,
      qtyReceived: qtyReceived ?? this.qtyReceived,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      qcStatus: qcStatus ?? this.qcStatus,
    );
  }
}
