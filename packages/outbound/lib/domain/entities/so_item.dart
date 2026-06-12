class SoItem {
  final int productId;
  final int qtyOrdered;
  final String? productName;
  final String? sku;
  final String? barcode;
  final String? unitOfMeasure;
  final int qtyPicked;
  final int qtyVerified;

  const SoItem({
    required this.productId,
    required this.qtyOrdered,
    this.productName,
    this.sku,
    this.barcode,
    this.unitOfMeasure,
    this.qtyPicked = 0,
    this.qtyVerified = 0,
  });
}
