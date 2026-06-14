import 'package:outbound/data/models/so_item_model.dart';

class SalesOrderModel {
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
  final List<SoItemModel> items;

  const SalesOrderModel({
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

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: _asInt(json['id']),
      soNumber: json['soNumber'] as String? ?? 'SO-${json['id']}',
      customerName: json['customerName'] as String? ?? '',
      companyName: json['companyName'] as String?,
      contactPerson: json['contactPerson'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      shippingAddress: json['shippingAddress'] as String? ?? '',
      provinceCode: json['provinceCode'] as String?,
      provinceName: json['provinceName'] as String?,
      cityCode: json['cityCode'] as String?,
      cityName: json['cityName'] as String?,
      districtCode: json['districtCode'] as String?,
      districtName: json['districtName'] as String?,
      postalCode: json['postalCode'] as String?,
      courierId: json['courierId'] == null ? null : _asInt(json['courierId']),
      courierCode: json['courierCode'] as String?,
      courierName: json['courierName'] as String?,
      courierServiceType: json['courierServiceType'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      requiredDeliveryDate: json['requiredDeliveryDate'] as String? ?? '',
      orderDate:
          json['orderDate'] as String? ??
          json['createdAt'] as String? ??
          json['requiredDeliveryDate'] as String? ??
          '',
      status: json['status'] as String? ?? 'Pending',
      totalOrderedQuantity: _asInt(json['totalOrderedQuantity']),
      totalPickedItems: _asInt(json['totalPickedItems']),
      totalVerifiedItems: _asInt(json['totalVerifiedItems']),
      progressPercentage: _asDouble(json['progressPercentage']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      items:
          (json['items'] as List<dynamic>?)
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

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
