import 'package:equatable/equatable.dart';
import 'package:inbound/domain/entities/po_item.dart';

class PurchaseOrder extends Equatable {
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

  @override
  List<Object?> get props => [
    id,
    poNumber,
    supplierName,
    status,
    invoiceNumber,
    isQcCompleted,
    eta,
    carrier,
    totalQtyExpected,
    totalQtyReceived,
    totalItemCount,
    qcCompletedCount,
    putAwayCompletedCount,
    createdAt,
    items,
  ];
}
