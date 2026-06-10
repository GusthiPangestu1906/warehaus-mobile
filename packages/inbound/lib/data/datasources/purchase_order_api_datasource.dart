import 'package:dio/dio.dart';
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
}
