import 'package:outbound/domain/entities/so_item.dart';

class SalesOrder {
  final int id;
  final String soNumber;
  final String customerName;
  final String? companyName;
  final String? contactPerson;
  final String? phoneNumber;
  final String shippingAddress;
  final String? provinceCode;
  final String? provinceName;
  final String? cityCode;
  final String? cityName;
  final String? districtCode;
  final String? districtName;
  final String? postalCode;
  final int? courierId;
  final String? courierCode;
  final String? courierName;
  final String? courierServiceType;
  final String? trackingNumber;
  final String requiredDeliveryDate;
  final String orderDate;
  final String status;
  final int totalOrderedQuantity;
  final int totalPickedItems;
  final int totalVerifiedItems;
  final double progressPercentage;
  final bool isCompleted;
  final List<SoItem> items;

  const SalesOrder({
    required this.id,
    required this.soNumber,
    required this.customerName,
    this.companyName,
    this.contactPerson,
    this.phoneNumber,
    required this.shippingAddress,
    this.provinceCode,
    this.provinceName,
    this.cityCode,
    this.cityName,
    this.districtCode,
    this.districtName,
    this.postalCode,
    this.courierId,
    this.courierCode,
    this.courierName,
    this.courierServiceType,
    this.trackingNumber,
    required this.requiredDeliveryDate,
    required this.orderDate,
    required this.status,
    required this.totalOrderedQuantity,
    required this.totalPickedItems,
    required this.totalVerifiedItems,
    required this.progressPercentage,
    required this.isCompleted,
    required this.items,
  });
}
