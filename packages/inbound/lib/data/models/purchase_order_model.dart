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
    required super.eta,
    required super.carrier,
    required super.totalQtyExpected,
    required super.totalQtyReceived,
    required super.createdAt,
    required List<ItemModel> super.items,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderModel(
        id: json["id"],
        poNumber: json["poNumber"],
        supplierName: json["supplierName"],
        status: json["status"],
        eta: DateTime.parse(json["eta"]),
        carrier: json["carrier"],
        totalQtyExpected: json["totalQtyExpected"],
        totalQtyReceived: json["totalQtyReceived"],
        createdAt: DateTime.parse(json["createdAt"]),
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
    super.productCode,
    super.sku,
    super.productName,
    super.qcStatus,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json["id"],
    productId: json["productId"],
    qtyExpected: json["qtyExpected"],
    qtyReceived: json["qtyReceived"],
    productCode: json["productCode"],
    productName: json["productName"],
    sku: json["sku"],
    qcStatus: json["qcStatus"],
  );
}
