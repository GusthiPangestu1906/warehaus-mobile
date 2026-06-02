import 'dart:convert';

import 'package:inbound/domain/entities/po_item.dart';
import 'package:inbound/domain/entities/purchase_order.dart';

List<PurchaseOrderModel> purchaseOrderModelFromJson(String str) =>
    List<PurchaseOrderModel>.from(
      json.decode(str).map((x) => PurchaseOrderModel.fromJson(x)),
    );

class PurchaseOrderModel extends PurchaseOrder {
  PurchaseOrderModel({
    required super.id,
    required super.poNumber,
    required super.supplierName,
    required super.status,
    required super.totalQtyExpected,
    required super.totalQtyReceived,
    required List<ItemModel> super.items,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderModel(
        id: json["id"],
        poNumber: json["poNumber"],
        supplierName: json["supplierName"],
        status: json["status"],
        totalQtyExpected: json["totalQtyExpected"],
        totalQtyReceived: json["totalQtyReceived"],
        items: List<ItemModel>.from(
          json["items"].map((x) => ItemModel.fromJson(x)),
        ),
      );
}

class ItemModel extends PoItem {
  ItemModel({
    required super.id,
    required super.productId,
    required super.qtyExpected,
    required super.qtyReceived,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json["id"],
    productId: json["productId"],
    qtyExpected: json["qtyExpected"],
    qtyReceived: json["qtyReceived"],
  );
}
