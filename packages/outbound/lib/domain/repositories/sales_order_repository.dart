import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_tracking_params.dart';

abstract class SalesOrderRepository {
  Future<List<SalesOrder>> getSalesOrders();
  Future<SalesOrder> getSalesOrderById(int id);
  Future<void> createSalesOrder(CreateSalesOrderParams params);
  Future<void> updateSalesOrder(UpdateSalesOrderParams params);
  Future<void> deleteSalesOrder(int id);
  Future<void> updateTrackingNumber(UpdateSalesOrderTrackingParams params);
}
