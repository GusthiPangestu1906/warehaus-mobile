import 'package:dio/dio.dart';
import 'package:outbound/data/models/sales_order_model.dart';

class SalesOrderApiDatasource {
  final Dio dio;
  SalesOrderApiDatasource(this.dio);

  static const String _salesOrderPath = '/api/outbound/sales-orders';

  Future<List<SalesOrderModel>> getSalesOrders() async {
    final response = await dio.get(_salesOrderPath);
    final data = response.data;
    final rawList = data is List
        ? data
        : (data is Map<String, dynamic>
                  ? data['value'] as List<dynamic>?
                  : null) ??
              const [];
    return rawList
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

  Future<void> updateTrackingNumber(int id, String trackingNumber) async {
    await dio.patch(
      '$_salesOrderPath/$id/tracking',
      data: {'trackingNumber': trackingNumber},
    );
  }
}
