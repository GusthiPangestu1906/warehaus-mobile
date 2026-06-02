import 'package:inbound/domain/entities/po_item.dart';

class PurchaseOrder {
  final int id;
  final String poNumber;
  final String supplierName;
  final String status;
  final int totalQtyExpected;
  final int totalQtyReceived;
  final List<PoItem> items;

  const PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierName,
    required this.status,
    required this.totalQtyExpected,
    required this.totalQtyReceived,
    required this.items,
  });
}
