import 'package:inbound/domain/entities/po_item.dart';

class PurchaseOrder {
  final int id;
  final String poNumber;
  final String supplierName;
  final String status;
  final String? invoiceNumber;
  final bool isQcCompleted;
  final DateTime eta;
  final String carrier;
  final int totalQtyExpected;
  final int totalQtyReceived;
  final int totalItemCount;
  final int qcCompletedCount;
  final int putAwayCompletedCount;
  final DateTime createdAt;
  final List<PoItem> items;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.status,
    this.invoiceNumber,
    required this.isQcCompleted,
    required this.eta,
    required this.carrier,
    required this.totalQtyExpected,
    required this.totalQtyReceived,
    required this.totalItemCount,
    required this.qcCompletedCount,
    required this.putAwayCompletedCount,
    required this.createdAt,
    required this.items,
  });

  PurchaseOrder copyWith({
    int? id,
    String? poNumber,
    String? supplierName,
    String? status,
    String? invoiceNumber,
    bool? isQcCompleted,
    DateTime? eta,
    String? carrier,
    int? totalQtyExpected,
    int? totalQtyReceived,
    int? totalItemCount,
    int? qcCompletedCount,
    int? putAwayCompletedCount,
    DateTime? createdAt,
    List<PoItem>? items,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      isQcCompleted: isQcCompleted ?? this.isQcCompleted,
      eta: eta ?? this.eta,
      carrier: carrier ?? this.carrier,
      totalQtyExpected: totalQtyExpected ?? this.totalQtyExpected,
      totalQtyReceived: totalQtyReceived ?? this.totalQtyReceived,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      qcCompletedCount: qcCompletedCount ?? this.qcCompletedCount,
      putAwayCompletedCount:
          putAwayCompletedCount ?? this.putAwayCompletedCount,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
