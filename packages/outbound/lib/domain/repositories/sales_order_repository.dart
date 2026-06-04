import 'package:outbound/domain/entities/sales_order.dart';

abstract class SalesOrderRepository {
  Future<List<SalesOrder>> getSalesOrders();
  Future<SalesOrder> getSalesOrderById(int id);
  Future<void> createSalesOrder({
    required String customerName,
    required String shippingAddress,
    required String courier,
    required String requiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  });
  Future<void> deleteSalesOrder(int id);
}
