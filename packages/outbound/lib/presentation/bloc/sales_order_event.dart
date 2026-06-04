abstract class SalesOrderEvent {}

class GetSalesOrdersEvent extends SalesOrderEvent {}

class CreateSalesOrderEvent extends SalesOrderEvent {
  final String customerName;
  final String shippingAddress;
  final String courier;
  final String requiredDeliveryDate;
  final List<Map<String, dynamic>> items;

  CreateSalesOrderEvent({
    required this.customerName,
    required this.shippingAddress,
    required this.courier,
    required this.requiredDeliveryDate,
    required this.items,
  });
}

class DeleteSalesOrderEvent extends SalesOrderEvent {
  final int id;
  DeleteSalesOrderEvent(this.id);
}
