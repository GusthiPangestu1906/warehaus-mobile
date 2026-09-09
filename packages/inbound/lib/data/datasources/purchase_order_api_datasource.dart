import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/data/models/carrier_model.dart';
import 'package:inbound/data/models/pa_next_item_model.dart';
import 'package:inbound/data/models/purchase_order_model.dart';
import 'package:inbound/data/models/qc_next_item_model.dart';

class PurchaseOrderApiDatasource {
  final Dio dio;
  PurchaseOrderApiDatasource(this.dio);

  static const String _purchaseOrderPath = '/purchase-orders';
  static const String _inboundPath = '/inbound';

  Future<List<PurchaseOrderModel>> getPurchaseOrders(DateTime? date) async {
    final response = await dio.get(
      _purchaseOrderPath,
      queryParameters: date == null ? null : {'date': date.toIso8601String()},
    );
    return (response.data as List)
        .map((e) => PurchaseOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PurchaseOrderModel> getPurchaseOrderDetail(int id) async {
    final response = await dio.get('$_purchaseOrderPath/$id');
    return PurchaseOrderModel.fromJson(response.data);
  }

  Future<Unit> createPurchaseOrder(Map<String, dynamic> data) async {
    await dio.post(_purchaseOrderPath, data: data);
    return unit;
  }

  Future<Unit> updatePurchaseOrder(int id, Map<String, dynamic> data) async {
    await dio.put('$_purchaseOrderPath/$id', data: data);
    return unit;
  }

  Future<Unit> invoiceUpdate(int id, String invoiceNumber) async {
    await dio.put(
      '$_purchaseOrderPath/$id/invoice',
      data: {'invoiceNumber': invoiceNumber},
    );
    return unit;
  }

  Future<Unit> deletePurchaseOrder(int id) async {
    await dio.delete('$_purchaseOrderPath/$id');
    return unit;
  }

  Future<List<int>> downloadPurchaseOrderPdf(int id) async {
    final response = await dio.get<List<int>>(
      '$_purchaseOrderPath/$id/pdf',
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Empty PDF response from server.');
    }

    return bytes;
  }

  Future<QcNextItemModel> getQcNextItem(int poId) async {
    final response = await dio.get('$_purchaseOrderPath/$poId/qc-next');
    return QcNextItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Unit> submitQc(Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);

    await dio.post(
      _inboundPath,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return unit;
  }

  Future<PaNextItemModel> getPaNextItem(int poId) async {
    final response = await dio.get('$_inboundPath/put-away/next/$poId');
    return PaNextItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Unit> submitPa(Map<String, dynamic> data, int receivingLogId) async {
    await dio.post('$_inboundPath/$receivingLogId/put-away', data: data);
    return unit;
  }

  Future<List<CarrierModel>> getCarriers() async {
    final response = await dio.get('/couriers');
    return (response.data as List)
        .map((e) => CarrierModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
