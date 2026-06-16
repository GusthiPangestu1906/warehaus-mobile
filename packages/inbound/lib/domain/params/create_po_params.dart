import 'dart:convert';

CreatePoParams createPoParamsFromJson(String str) =>
    CreatePoParams.fromJson(json.decode(str));

String createPoParamsToJson(CreatePoParams data) => json.encode(data.toJson());

class CreatePoParams {
  final String supplierName;
  final DateTime eta;
  final String carrier;
  final List<CreatePoItemParams> items;

  CreatePoParams({
    required this.supplierName,
    required this.eta,
    required this.carrier,
    required this.items,
  });

  factory CreatePoParams.fromJson(Map<String, dynamic> json) => CreatePoParams(
    supplierName: json["supplierName"],
    eta: DateTime.parse(json["eta"]),
    carrier: json["carrier"],
    items: List<CreatePoItemParams>.from(
      json["items"].map((x) => CreatePoItemParams.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() {
    final etaDate =
        '${eta.year.toString().padLeft(4, '0')}-'
        '${eta.month.toString().padLeft(2, '0')}-'
        '${eta.day.toString().padLeft(2, '0')}';

    return {
      "supplierName": supplierName.trim(),
      "eta": etaDate,
      "carrier": carrier.trim(),
      "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
  }
}

class CreatePoItemParams {
  final int productId;
  final int qtyExpected;

  CreatePoItemParams({required this.productId, required this.qtyExpected});

  factory CreatePoItemParams.fromJson(Map<String, dynamic> json) =>
      CreatePoItemParams(
        productId: json["productId"],
        qtyExpected: json["qtyExpected"],
      );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "qtyExpected": qtyExpected,
  };
}
