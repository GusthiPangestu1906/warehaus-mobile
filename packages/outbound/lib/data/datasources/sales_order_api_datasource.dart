import 'package:dio/dio.dart';
import 'package:outbound/data/models/sales_order_model.dart';

class SalesOrderApiDatasource {
  final Dio dio;
  SalesOrderApiDatasource(this.dio);

  static const String _salesOrderPath = '/api/outbound/sales-orders';

  Future<List<SalesOrderModel>> getSalesOrders() async {
    final response = await dio.get(_salesOrderPath);
    return (response.data as List)
        .map((e) => SalesOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SalesOrderModel> getSalesOrderById(int id) async {
    final response = await dio.get('$_salesOrderPath/$id');
    return SalesOrderModel.fromJson(response.data);
  }

  Future<void> createSalesOrder(Map<String, dynamic> data) async {
    await dio.post(_salesOrderPath, data: data);
  }

  Future<void> deleteSalesOrder(int id) async {
    await dio.delete('$_salesOrderPath/$id');
  }
}