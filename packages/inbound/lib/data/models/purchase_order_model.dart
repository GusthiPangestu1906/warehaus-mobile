import 'package:inbound/domain/entities/po_item.dart';
import 'package:inbound/domain/entities/purchase_order.dart';

class PurchaseOrderModel extends PurchaseOrder {
  PurchaseOrderModel({
    required super.id,
    required super.poNumber,
    required super.supplierName,
    required super.status,
    super.invoiceNumber,
    required super.isQcCompleted,
    required super.eta,
    required super.carrier,
    required super.totalQtyExpected,
    required super.totalQtyReceived,
    required super.totalItemCount,
    required super.qcCompletedCount,
    required super.putAwayCompletedCount,
    required super.createdAt,
    required List<ItemModel> super.items,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderModel(
        id: json["id"],
        poNumber: json["poNumber"],
        supplierName: json["supplierName"],
        status: json["status"],
        invoiceNumber: json["invoiceNumber"],
        isQcCompleted: json["isQcCompleted"],
        eta: DateTime.parse(json["eta"]),
        carrier: json["carrier"],
        totalQtyExpected: json["totalQtyExpected"],
        totalQtyReceived: json["totalQtyReceived"],
        totalItemCount: json["totalItemCount"] ?? json["items"]?.length ?? 0,
        qcCompletedCount: json["qcCompletedCount"] ?? 0,
        putAwayCompletedCount: json["putAwayCompletedCount"] ?? 0,
        createdAt: DateTime.parse(json["createdAt"]),
        items: List<ItemModel>.from(
          json["items"].map((x) => ItemModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poNumber': poNumber,
      'supplierName': supplierName,
      'status': status,
      'invoiceNumber': invoiceNumber,
      'isQcCompleted': isQcCompleted,
      'eta': eta,
      'carrier': carrier,
      'totalQtyExpected': totalQtyExpected,
      'totalQtyReceived': totalQtyReceived,
      'totalItemCount': totalItemCount,
      'qcCompletedCount': qcCompletedCount,
      'putAwayCompletedCount': putAwayCompletedCount,
      'createdAt': createdAt,
      'items': items,
    };
  }

  factory PurchaseOrderModel.fromEntity(PurchaseOrder entity) {
    return PurchaseOrderModel(
      id: entity.id,
      poNumber: entity.poNumber,
      supplierName: entity.supplierName,
      status: entity.status,
      invoiceNumber: entity.invoiceNumber,
      isQcCompleted: entity.isQcCompleted,
      eta: entity.eta,
      carrier: entity.carrier,
      totalQtyExpected: entity.totalQtyExpected,
      totalQtyReceived: entity.totalQtyReceived,
      totalItemCount: entity.totalItemCount,
      qcCompletedCount: entity.qcCompletedCount,
      putAwayCompletedCount: entity.putAwayCompletedCount,
      createdAt: entity.createdAt,
      items: entity.items.map((e) => ItemModel.fromEntity(e)).toList(),
    );
  }
}

class ItemModel extends PoItem {
  ItemModel({
    required super.id,
    required super.productId,
    required super.qtyExpected,
    required super.qtyReceived,
    super.isQcCompleted,
    super.productCode,
    super.sku,
    super.productName,
    super.qcStatus,
    super.productDetail,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final productDetail = json["productDetail"] == null
        ? null
        : PoProductDetailModel.fromJson(
            json["productDetail"] as Map<String, dynamic>,
          );

    return ItemModel(
      id: json["id"],
      productId: json["productId"],
      qtyExpected: json["qtyExpected"],
      qtyReceived: json["qtyReceived"],
      isQcCompleted: json["isQcCompleted"] ?? false,
      productCode: json["productCode"],
      productName: json["productName"] ?? productDetail?.productName,
      sku: json["sku"] ?? productDetail?.sku,
      qcStatus: json["qcStatus"],
      productDetail: productDetail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'qtyExpected': qtyExpected,
      'qtyReceived': qtyReceived,
      'isQcCompleted': isQcCompleted,
      'productCode': productCode,
      'productName': productName,
      'sku': sku,
      'qcStatus': qcStatus,
      'productDetail': productDetail,
    };
  }

  factory ItemModel.fromEntity(PoItem entity) {
    return ItemModel(
      id: entity.id,
      productId: entity.productId,
      qtyExpected: entity.qtyExpected,
      qtyReceived: entity.qtyReceived,
      isQcCompleted: entity.isQcCompleted,
      productCode: entity.productCode,
      productName: entity.productName,
      sku: entity.sku,
      qcStatus: entity.qcStatus,
      productDetail: entity.productDetail,
    );
  }
}

class PoProductDetailModel extends PoProductDetail {
  const PoProductDetailModel({
    required super.id,
    required super.sku,
    required super.productName,
    required super.barcode,
    required super.unitOfMeasure,
    required super.categoryId,
  });

  factory PoProductDetailModel.fromJson(Map<String, dynamic> json) {
    return PoProductDetailModel(
      id: json["id"],
      sku: json["sku"],
      productName: json["productName"],
      barcode: json["barcode"],
      unitOfMeasure: json["unitOfMeasure"],
      categoryId: json["categoryId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'barcode': barcode,
      'unitOfMeasure': unitOfMeasure,
      'categoryId': categoryId,
    };
  }

  factory PoProductDetailModel.fromEntity(PoProductDetail entity) {
    return PoProductDetailModel(
      id: entity.id,
      sku: entity.sku,
      productName: entity.productName,
      barcode: entity.barcode,
      unitOfMeasure: entity.unitOfMeasure,
      categoryId: entity.categoryId,
    );
  }
}
