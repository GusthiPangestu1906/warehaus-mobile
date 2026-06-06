import 'package:outbound/domain/entities/so_item.dart';

class SalesOrder {
  final int id;
  final String customerName;
  final String? companyName;
  final String? contactPerson;
  final String? phoneNumber;
  final String shippingAddress;
  final String? provinceCode;
  final String? cityCode;
  final String? districtCode;
  final String? postalCode;
  final int? courierId;
  final String? courierName;
  final String? courierServiceType;
  final String requiredDeliveryDate;
  final String status;
  final List<SoItem> items;

  const SalesOrder({
    required this.id,
    required this.customerName,
    this.companyName,
    this.contactPerson,
    this.phoneNumber,
    required this.shippingAddress,
    this.provinceCode,
    this.cityCode,
    this.districtCode,
    this.postalCode,
    this.courierId,
    this.courierName,
    this.courierServiceType,
    required this.requiredDeliveryDate,
    required this.status,
    required this.items,
  });
}
