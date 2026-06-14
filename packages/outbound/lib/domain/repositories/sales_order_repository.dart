import 'package:outbound/domain/entities/sales_order.dart';

abstract class SalesOrderRepository {
  Future<List<SalesOrder>> getSalesOrders();
  Future<SalesOrder> getSalesOrderById(int id);
  Future<void> createSalesOrder({
    required String customerName,
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
    required String shippingAddress,
    required String provinceCode,
    required String cityCode,
    required String districtCode,
    required String postalCode,
    required int courierId,
    required String requiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  });
  Future<void> updateSalesOrder({
    required int id,
    required String customerName,
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
    required String shippingAddress,
    required String provinceCode,
    required String cityCode,
    required String districtCode,
    required String postalCode,
    required int courierId,
    required String requiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  });
  Future<void> deleteSalesOrder(int id);
  Future<void> updateTrackingNumber(int id, String trackingNumber);
}
