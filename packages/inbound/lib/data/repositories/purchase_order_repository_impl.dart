import 'package:inbound/data/datasources/purchase_order_api_datasource.dart';
import 'package:inbound/data/models/purchase_order_model.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class PurchaseOrderRepositoryImpl extends PurchaseOrderRepository {
  final PurchaseOrderApiDatasource apiDatasource;
  PurchaseOrderRepositoryImpl(this.apiDatasource);

  @override
  Future<List<PurchaseOrderModel>> getPurchaseOrders() async {
    return await apiDatasource.getPurchaseOrders();
  }

  @override
  Future<PurchaseOrderModel> getPurchaseOrderDetail(int id) async {
    return await apiDatasource.getPurchaseOrderDetail(id);
  }

  @override
  Future<void> createPurchaseOrder(CreatePoParams params) async {
    await apiDatasource.createPurchaseOrder(params.toJson());
  }
}
