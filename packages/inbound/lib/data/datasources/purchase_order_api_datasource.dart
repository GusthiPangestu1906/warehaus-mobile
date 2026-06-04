import 'package:dio/dio.dart';
import 'package:inbound/data/models/purchase_order_model.dart';

class PurchaseOrderApiDatasource {
  final Dio dio;
  PurchaseOrderApiDatasource(this.dio);

  static const String _purchaseOrderPath = '/purchase-orders';

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
}
