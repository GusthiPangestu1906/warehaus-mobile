import 'package:outbound/domain/params/create_sales_order_params.dart';

class UpdateSalesOrderParams {
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

  const UpdateSalesOrderParams({
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

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'note': note,
      'shippingAddress': shippingAddress,
      'provinceCode': provinceCode,
      'cityCode': cityCode,
      'districtCode': districtCode,
      'postalCode': postalCode,
      'courierId': courierId,
      'requiredDeliveryDate': requiredDeliveryDate,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
