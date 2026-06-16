import 'dart:io';

import 'package:dio/dio.dart';
import 'package:outbound/data/models/sales_order_model.dart';

class SalesOrderApiDatasource {
  final Dio dio;
  SalesOrderApiDatasource(this.dio);

  static const String _salesOrderPath = '/outbound/sales-orders';

  Future<List<SalesOrderModel>> getSalesOrders({String? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }

    final response = await dio.get(
      _salesOrderPath,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
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

  Future<Map<String, dynamic>> startPicking(int id) async {
    final response = await dio.post(
      '$_salesOrderPath/$id/picking/start',
      data: const <String, dynamic>{},
      options: Options(contentType: Headers.jsonContentType),
    );
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

  Future<Map<String, dynamic>> verifyPackingItem({
    required int salesOrderId,
    required int salesOrderItemId,
    required int packedQty,
  }) async {
    try {
      final response = await dio.post(
        '$_salesOrderPath/$salesOrderId/packing/items/$salesOrderItemId/complete',
        data: {'packedQty': packedQty},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode != 404 && statusCode != 405) rethrow;

      final response = await dio.post(
        '$_salesOrderPath/$salesOrderId/packing/items/$salesOrderItemId/verify',
        data: {'verifiedQty': packedQty, 'packedQty': packedQty},
      );
      return response.data as Map<String, dynamic>;
    }
  }

  Future<void> completePacking(
    int salesOrderId, {
    List<Map<String, dynamic>> verifiedItems = const [],
  }) async {
    await dio.post(
      '$_salesOrderPath/$salesOrderId/packing/complete',
      data: {'verifiedItems': verifiedItems},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<String> downloadLabelPdf(int salesOrderId, {String? soNumber}) async {
    final response = await dio.get<List<int>>(
      '$_salesOrderPath/$salesOrderId/label.pdf',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {Headers.acceptHeader: 'application/pdf'},
      ),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Label PDF kosong dari backend');
    }

    final safeName = _safeFileName(soNumber ?? 'sales-order-$salesOrderId');
    return _writePdfToDownload(bytes, '$safeName-label.pdf');
  }

  bool _isCreatedButRouteResponseFailed(DioException error) {
    if (error.response?.statusCode != 409) return false;
    final responseText = error.response?.data.toString() ?? '';
    return responseText.contains('No route matches the supplied values');
  }
}

String _safeFileName(String value) {
  final safe = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-');
  return safe.isEmpty ? 'sales-order-label' : safe;
}

Future<String> _writePdfToDownload(List<int> bytes, String fileName) async {
  final directories = [
    Directory('/storage/emulated/0/Download/WareHaus'),
    Directory('${Directory.systemTemp.path}/WareHaus'),
  ];

  Object? lastError;
  for (final directory in directories) {
    try {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      lastError = e;
    }
  }

  throw Exception('Gagal menyimpan label PDF: $lastError');
}
