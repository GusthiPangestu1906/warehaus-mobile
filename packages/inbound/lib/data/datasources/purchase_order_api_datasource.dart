import 'package:dio/dio.dart';

class PurchaseOrderApiDatasource {
  final Dio dio;
  PurchaseOrderApiDatasource(this.dio);

  static const String _purchaseOrderPath = '/purchase-orders';

  Future<void> createPurchaseOrder(Map<String, dynamic> data) async {
    await dio.post(_purchaseOrderPath, data: data);
  }
}
