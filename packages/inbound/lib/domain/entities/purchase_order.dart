import 'package:inbound/domain/entities/po_item.dart';

class PurchaseOrder {
  final int id;
  final String poNumber;
  final String supplierName;
  final String status;
  final DateTime eta;
  final String carrier;
  final int totalQtyExpected;
  final int totalQtyReceived;
  final DateTime createdAt;
  final List<PoItem> items;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.status,
    required this.eta,
    required this.carrier,
    required this.totalQtyExpected,
    required this.totalQtyReceived,
    required this.createdAt,
    required this.items,
  });

  PurchaseOrder copyWith({
    int? id,
    String? poNumber,
    String? supplierName,
    String? status,
    DateTime? eta,
    String? carrier,
    int? totalQtyExpected,
    int? totalQtyReceived,
    DateTime? createdAt,
    List<PoItem>? items,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      eta: eta ?? this.eta,
      carrier: carrier ?? this.carrier,
      totalQtyExpected: totalQtyExpected ?? this.totalQtyExpected,
      totalQtyReceived: totalQtyReceived ?? this.totalQtyReceived,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
