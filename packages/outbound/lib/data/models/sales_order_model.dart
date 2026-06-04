import 'package:outbound/data/models/so_item_model.dart';

class SalesOrderModel {
  final int id;
  final String customerName;
  final String shippingAddress;
  final String courier;
  final String requiredDeliveryDate;
  final String status;
  final List<SoItemModel> items;

  const SalesOrderModel({
    required this.id,
    required this.customerName,
    required this.shippingAddress,
    required this.courier,
    required this.requiredDeliveryDate,
    required this.status,
    required this.items,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id'] as int,
      customerName: json['customerName'] as String? ?? '',
      shippingAddress: json['shippingAddress'] as String? ?? '',
      courier: json['courier'] as String? ?? '',
      requiredDeliveryDate: json['requiredDeliveryDate'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SoItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'shippingAddress': shippingAddress,
      'courier': courier,
      'requiredDeliveryDate': requiredDeliveryDate,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}