class SubmitPaParams {
  const SubmitPaParams({required this.itemId, required this.shelves});

  final int itemId;
  final List<ShelfPutAway> shelves;

  factory SubmitPaParams.fromJson(Map<String, dynamic> json) => SubmitPaParams(
    itemId: json["itemId"],
    shelves: List<ShelfPutAway>.from(
      json["shelf"].map((x) => ShelfPutAway.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "itemId": itemId,
    "shelf": List<dynamic>.from(shelves.map((x) => x.toJson())),
  };
}

class ShelfPutAway {
  const ShelfPutAway({required this.shelfId, required this.quantity});

  final int shelfId;
  final int quantity;

  factory ShelfPutAway.fromJson(Map<String, dynamic> json) =>
      ShelfPutAway(shelfId: json["shelfId"], quantity: json["quantity"]);

  Map<String, dynamic> toJson() => {"shelfId": shelfId, "quantity": quantity};
}
