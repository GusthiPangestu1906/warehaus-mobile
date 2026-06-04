class SoItem {
  final int productId;
  final int qtyOrdered;
  final String? productName;

  const SoItem({
    required this.productId,
    required this.qtyOrdered,
    this.productName,
  });
}
