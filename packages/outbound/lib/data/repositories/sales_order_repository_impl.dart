import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/data/models/sales_order_model.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/entities/so_item.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';

class SalesOrderRepositoryImpl implements SalesOrderRepository {
  final SalesOrderApiDatasource apiDatasource;
  SalesOrderRepositoryImpl(this.apiDatasource);

  SalesOrder _toEntity(SalesOrderModel m) => SalesOrder(
        id: m.id,
        customerName: m.customerName,
        shippingAddress: m.shippingAddress,
        courier: m.courier,
        requiredDeliveryDate: m.requiredDeliveryDate,
        status: m.status,
        items: m.items
            .map((e) => SoItem(
                  productId: e.productId,
                  qtyOrdered: e.qtyOrdered,
                  productName: e.productName,
                ))
            .toList(),
      );

  @override
  Future<List<SalesOrder>> getSalesOrders() async {
    final list = await apiDatasource.getSalesOrders();
    return list.map(_toEntity).toList();
  }

  @override
  Future<SalesOrder> getSalesOrderById(int id) async {
    final model = await apiDatasource.getSalesOrderById(id);
    return _toEntity(model);
  }

  @override
  Future<void> createSalesOrder({
    required String customerName,
    required String shippingAddress,
    required String courier,
    required String requiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    await apiDatasource.createSalesOrder({
      'customerName': customerName,
      'shippingAddress': shippingAddress,
      'courier': courier,
      'requiredDeliveryDate': requiredDeliveryDate,
      'items': items,
    });
  }

  @override
  Future<void> deleteSalesOrder(int id) async {
    await apiDatasource.deleteSalesOrder(id);
  }
}