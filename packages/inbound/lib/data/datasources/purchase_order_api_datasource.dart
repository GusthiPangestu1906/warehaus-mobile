import 'dart:io';

import 'package:dio/dio.dart';
import 'package:inbound/data/models/carrier_model.dart';
import 'package:inbound/data/models/pa_next_item_model.dart';
import 'package:inbound/data/models/purchase_order_model.dart';
import 'package:inbound/data/models/qc_next_item_model.dart';

class PurchaseOrderApiDatasource {
  final Dio dio;
  PurchaseOrderApiDatasource(this.dio);

  static const String _purchaseOrderPath = '/purchase-orders';
  static const String _inboundPath = '/inbound';

  Future<List<PurchaseOrderModel>> getPurchaseOrders() async {
    final response = await dio.get(_purchaseOrderPath);
    return (response.data as List)
        .map((e) => PurchaseOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PurchaseOrderModel> getPurchaseOrderDetail(int id) async {
    final response = await dio.get('$_purchaseOrderPath/$id');
    return PurchaseOrderModel.fromJson(response.data);
  }

  Future<void> createPurchaseOrder(Map<String, dynamic> data) async {
    await dio.post(_purchaseOrderPath, data: data);
  }

  Future<void> invoiceUpdate(int id, String invoiceNumber) async {
    await dio.put(
      '$_purchaseOrderPath/$id/invoice',
      data: {'invoiceNumber': invoiceNumber},
    );
  }

  Future<void> deletePurchaseOrder(int id) async {
    await dio.delete('$_purchaseOrderPath/$id');
  }

  Future<String> downloadPurchaseOrderPdf(int id, String poNumber) async {
    final response = await dio.get<List<int>>(
      '$_purchaseOrderPath/$id/pdf',
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Empty PDF response from server.');
    }

    final fileName = '${_sanitizeFileName(poNumber)}.pdf';
    final targetDir = await _resolveDownloadDirectory();
    final file = File('${targetDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    return file.path;
  }

  Future<QcNextItemModel> getQcNextItem(int poId) async {
    final response = await dio.get('$_purchaseOrderPath/$poId/qc-next');
    return QcNextItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> submitQc(Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);

    await dio.post(
      _inboundPath,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  Future<PaNextItemModel> getPaNextItem(int poId) async {
    final response = await dio.get('$_inboundPath/put-away/next/$poId');
    return PaNextItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> submitPa(Map<String, dynamic> data, int receivingLogId) async {
    await dio.post('$_inboundPath/$receivingLogId/put-away', data: data);
  }

  Future<Directory> _resolveDownloadDirectory() async {
    final downloadDir = Directory('/storage/emulated/0/Download/WareHaus');

    try {
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } catch (_) {
      final fallbackDir = Directory('${Directory.systemTemp.path}/WareHaus');
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      return fallbackDir;
    }
  }

  String _sanitizeFileName(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  Future<List<CarrierModel>> getCarriers() async {
    final response = await dio.get('/couriers');
    return (response.data as List)
        .map((e) => CarrierModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
