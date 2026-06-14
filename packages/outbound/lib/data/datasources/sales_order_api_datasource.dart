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
    try {
      await dio.post(_salesOrderPath, data: data);
    } on DioException catch (e) {
      if (_isCreatedButRouteResponseFailed(e)) return;
      rethrow;
    }
  }

  Future<void> updateSalesOrder(int id, Map<String, dynamic> data) async {
    try {
      await dio.put('$_salesOrderPath/$id', data: data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        await dio.patch('$_salesOrderPath/$id', data: data);
        return;
      }
      rethrow;
    }
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

  Future<Map<String, dynamic>> getPickingNextTask(int id) async {
    final response = await dio.get('$_salesOrderPath/$id/picking/next-task');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> completePickingTask({
    required int salesOrderId,
    required int salesOrderItemId,
    required int shelfId,
    required int pickedQty,
  }) async {
    final response = await dio.post(
      '$_salesOrderPath/$salesOrderId/picking/items/$salesOrderItemId/complete',
      data: {'shelfId': shelfId, 'pickedQty': pickedQty},
    );
    return response.data as Map<String, dynamic>;
  }

  bool _isCreatedButRouteResponseFailed(DioException error) {
    if (error.response?.statusCode != 409) return false;
    final responseText = error.response?.data.toString() ?? '';
    return responseText.contains('No route matches the supplied values');
  }
}
