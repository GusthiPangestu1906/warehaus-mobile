class SoItemModel {
  final int productId;
  final int qtyOrdered;
  final String? productName;

  const SoItemModel({
    required this.productId,
    required this.qtyOrdered,
    this.productName,
  });

  factory SoItemModel.fromJson(Map<String, dynamic> json) {
    return SoItemModel(
      productId: json['productId'] as int,
      qtyOrdered: json['qtyOrdered'] as int,
      productName: json['productName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'qtyOrdered': qtyOrdered,
    };
  }
}