import 'package:outbound/data/models/so_item_model.dart';
import 'package:outbound/domain/entities/sales_order.dart';

class SalesOrderModel extends SalesOrder {
  const SalesOrderModel({
    required super.id,
    required super.soNumber,
    required super.customerName,
    super.companyName,
    super.contactPerson,
    super.phoneNumber,
    super.note,
    required super.shippingAddress,
    super.provinceCode,
    super.provinceName,
    super.cityCode,
    super.cityName,
    super.districtCode,
    super.districtName,
    super.postalCode,
    super.courierId,
    super.courierCode,
    super.courierName,
    super.courierServiceType,
    super.trackingNumber,
    required super.requiredDeliveryDate,
    required super.orderDate,
    required super.status,
    required super.totalOrderedQuantity,
    required super.totalPickedItems,
    required super.totalVerifiedItems,
    required super.progressPercentage,
    required super.isCompleted,
    required super.items,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: _asInt(json['id']),
      soNumber: json['soNumber'] as String? ?? 'SO-${json['id']}',
      customerName: json['customerName'] as String? ?? '',
      companyName: json['companyName'] as String?,
      contactPerson: json['contactPerson'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      note:
          json['note'] as String? ??
          json['notes'] as String? ??
          json['remarks'] as String?,
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

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'companyName': companyName ?? '',
      'contactPerson': contactPerson ?? '',
      'phoneNumber': phoneNumber ?? '',
      'note': note ?? '',
      'shippingAddress': shippingAddress,
      'provinceCode': provinceCode ?? '',
      'cityCode': cityCode ?? '',
      'districtCode': districtCode ?? '',
      'postalCode': postalCode ?? '',
      'courierId': courierId,
      'requiredDeliveryDate': requiredDeliveryDate,
      'items': items.map((e) => (e as SoItemModel).toJson()).toList(),
    };
  }

  factory SalesOrderModel.fromEntity(SalesOrder entity) {
    return SalesOrderModel(
      id: entity.id,
      soNumber: entity.soNumber,
      customerName: entity.customerName,
      companyName: entity.companyName,
      contactPerson: entity.contactPerson,
      phoneNumber: entity.phoneNumber,
      note: entity.note,
      shippingAddress: entity.shippingAddress,
      provinceCode: entity.provinceCode,
      provinceName: entity.provinceName,
      cityCode: entity.cityCode,
      cityName: entity.cityName,
      districtCode: entity.districtCode,
      districtName: entity.districtName,
      postalCode: entity.postalCode,
      courierId: entity.courierId,
      courierCode: entity.courierCode,
      courierName: entity.courierName,
      courierServiceType: entity.courierServiceType,
      trackingNumber: entity.trackingNumber,
      requiredDeliveryDate: entity.requiredDeliveryDate,
      orderDate: entity.orderDate,
      status: entity.status,
      totalOrderedQuantity: entity.totalOrderedQuantity,
      totalPickedItems: entity.totalPickedItems,
      totalVerifiedItems: entity.totalVerifiedItems,
      progressPercentage: entity.progressPercentage,
      isCompleted: entity.isCompleted,
      items: entity.items.map((e) => SoItemModel.fromEntity(e)).toList(),
    );
  }
}

extension SalesOrderModelMapper on SalesOrderModel {
  SalesOrder toEntity() {
    return SalesOrder(
      id: id,
      soNumber: soNumber,
      customerName: customerName,
      companyName: companyName,
      contactPerson: contactPerson,
      phoneNumber: phoneNumber,
      note: note,
      shippingAddress: shippingAddress,
      provinceCode: provinceCode,
      provinceName: provinceName,
      cityCode: cityCode,
      cityName: cityName,
      districtCode: districtCode,
      districtName: districtName,
      postalCode: postalCode,
      courierId: courierId,
      courierCode: courierCode,
      courierName: courierName,
      courierServiceType: courierServiceType,
      trackingNumber: trackingNumber,
      requiredDeliveryDate: requiredDeliveryDate,
      orderDate: orderDate,
      status: status,
      totalOrderedQuantity: totalOrderedQuantity,
      totalPickedItems: totalPickedItems,
      totalVerifiedItems: totalVerifiedItems,
      progressPercentage: progressPercentage,
      isCompleted: isCompleted,
      items: items.map((e) => (e as SoItemModel).toEntity()).toList(),
    );
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
