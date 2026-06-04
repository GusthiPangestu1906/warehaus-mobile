import 'package:outbound/domain/entities/so_item.dart';

class SalesOrder {
  final int id;
  final String customerName;
  final String shippingAddress;
  final String courier;
  final String requiredDeliveryDate;
  final String status;
  final List<SoItem> items;

  const SalesOrder({
    required this.id,
    required this.customerName,
    required this.shippingAddress,
    required this.courier,
    required this.requiredDeliveryDate,
    required this.status,
    required this.items,
  });
}
