abstract class SalesOrderEvent {}

class GetSalesOrdersEvent extends SalesOrderEvent {}

class CreateSalesOrderEvent extends SalesOrderEvent {
  final String customerName;
  final String companyName;
  final String contactPerson;
  final String phoneNumber;
  final String shippingAddress;
  final String provinceCode;
  final String cityCode;
  final String districtCode;
  final String postalCode;
  final int courierId;
  final String requiredDeliveryDate;
  final List<Map<String, dynamic>> items;

  CreateSalesOrderEvent({
    required this.customerName,
    required this.companyName,
    required this.contactPerson,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.provinceCode,
    required this.cityCode,
    required this.districtCode,
    required this.postalCode,
    required this.courierId,
    required this.requiredDeliveryDate,
    required this.items,
  });
}

class DeleteSalesOrderEvent extends SalesOrderEvent {
  final int id;
  DeleteSalesOrderEvent(this.id);
}
