import 'package:equatable/equatable.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';

abstract class SalesOrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetSalesOrdersEvent extends SalesOrderEvent {
  final String? date;
  GetSalesOrdersEvent({this.date});

  @override
  List<Object?> get props => [date];
}

class CreateSalesOrderEvent extends SalesOrderEvent {
  final String customerName;
  final String companyName;
  final String contactPerson;
  final String phoneNumber;
  final String note;
  final String shippingAddress;
  final String provinceCode;
  final String cityCode;
  final String districtCode;
  final String postalCode;
  final int courierId;
  final String requiredDeliveryDate;
  final List<SalesOrderItemParams> items;

  CreateSalesOrderEvent({
    required this.customerName,
    required this.companyName,
    required this.contactPerson,
    required this.phoneNumber,
    required this.note,
    required this.shippingAddress,
    required this.provinceCode,
    required this.cityCode,
    required this.districtCode,
    required this.postalCode,
    required this.courierId,
    required this.requiredDeliveryDate,
    required this.items,
  });

  @override
  List<Object?> get props => [
    customerName,
    companyName,
    contactPerson,
    phoneNumber,
    note,
    shippingAddress,
    provinceCode,
    cityCode,
    districtCode,
    postalCode,
    courierId,
    requiredDeliveryDate,
    items,
  ];
}

class DeleteSalesOrderEvent extends SalesOrderEvent {
  final int id;
  DeleteSalesOrderEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateSalesOrderEvent extends SalesOrderEvent {
  final int id;
  final String customerName;
  final String companyName;
  final String contactPerson;
  final String phoneNumber;
  final String note;
  final String shippingAddress;
  final String provinceCode;
  final String cityCode;
  final String districtCode;
  final String postalCode;
  final int courierId;
  final String requiredDeliveryDate;
  final List<SalesOrderItemParams> items;

  UpdateSalesOrderEvent({
    required this.id,
    required this.customerName,
    required this.companyName,
    required this.contactPerson,
    required this.phoneNumber,
    required this.note,
    required this.shippingAddress,
    required this.provinceCode,
    required this.cityCode,
    required this.districtCode,
    required this.postalCode,
    required this.courierId,
    required this.requiredDeliveryDate,
    required this.items,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    companyName,
    contactPerson,
    phoneNumber,
    note,
    shippingAddress,
    provinceCode,
    cityCode,
    districtCode,
    postalCode,
    courierId,
    requiredDeliveryDate,
    items,
  ];
}

class UpdateSalesOrderLocalStatusEvent extends SalesOrderEvent {
  final int id;
  final String status;
  final String? trackingNumber;
  final int? totalPickedItems;
  final int? totalVerifiedItems;
  final bool? isCompleted;

  UpdateSalesOrderLocalStatusEvent({
    required this.id,
    required this.status,
    this.trackingNumber,
    this.totalPickedItems,
    this.totalVerifiedItems,
    this.isCompleted,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    trackingNumber,
    totalPickedItems,
    totalVerifiedItems,
    isCompleted,
  ];
}

class UpdateSalesOrderTrackingEvent extends SalesOrderEvent {
  final int id;
  final String trackingNumber;

  UpdateSalesOrderTrackingEvent({
    required this.id,
    required this.trackingNumber,
  });

  @override
  List<Object?> get props => [id, trackingNumber];
}
