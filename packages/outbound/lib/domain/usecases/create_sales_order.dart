import 'package:outbound/domain/repositories/sales_order_repository.dart';

class CreateSalesOrder {
  final SalesOrderRepository repository;
  const CreateSalesOrder(this.repository);

  Future<void> call({
    required String customerName,
    required String shippingAddress,
    required String courier,
    required String requiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) =>
      repository.createSalesOrder(
        customerName: customerName,
        shippingAddress: shippingAddress,
        courier: courier,
        requiredDeliveryDate: requiredDeliveryDate,
        items: items,
      );
}
