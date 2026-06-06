import 'package:outbound/data/models/so_item_model.dart';

class SalesOrderModel {
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
  final List<SoItemModel> items;

  const SalesOrderModel({
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

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id'] as int,
      customerName: json['customerName'] as String? ?? '',
      companyName: json['companyName'] as String?,
      contactPerson: json['contactPerson'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      shippingAddress: json['shippingAddress'] as String? ?? '',
      provinceCode: json['provinceCode'] as String?,
      cityCode: json['cityCode'] as String?,
      districtCode: json['districtCode'] as String?,
      postalCode: json['postalCode'] as String?,
      courierId: json['courierId'] as int?,
      courierName: json['courierName'] as String?,
      courierServiceType: json['courierServiceType'] as String?,
      requiredDeliveryDate: json['requiredDeliveryDate'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SoItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'customerName': customerName,
      'companyName': companyName ?? '',
      'contactPerson': contactPerson ?? '',
      'phoneNumber': phoneNumber ?? '',
      'shippingAddress': shippingAddress,
      'provinceCode': provinceCode ?? '',
      'cityCode': cityCode ?? '',
      'districtCode': districtCode ?? '',
      'postalCode': postalCode ?? '',
      'courierId': courierId,
      'requiredDeliveryDate': requiredDeliveryDate,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}