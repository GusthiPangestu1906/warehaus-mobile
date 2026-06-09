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
    soNumber: m.soNumber,
    customerName: m.customerName,
    companyName: m.companyName,
    contactPerson: m.contactPerson,
    phoneNumber: m.phoneNumber,
    shippingAddress: m.shippingAddress,
    provinceCode: m.provinceCode,
    cityCode: m.cityCode,
    districtCode: m.districtCode,
    postalCode: m.postalCode,
    courierId: m.courierId,
    courierName: m.courierName,
    courierServiceType: m.courierServiceType,
    trackingNumber: m.trackingNumber,
    requiredDeliveryDate: m.requiredDeliveryDate,
    orderDate: m.orderDate,
    status: m.status,
    totalOrderedQuantity: m.totalOrderedQuantity,
    totalPickedItems: m.totalPickedItems,
    totalVerifiedItems: m.totalVerifiedItems,
    progressPercentage: m.progressPercentage,
    isCompleted: m.isCompleted,
    items: m.items
        .map(
          (e) => SoItem(
            productId: e.productId,
            qtyOrdered: e.qtyOrdered,
            productName: e.productName,
          ),
        )
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
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
    required String shippingAddress,
    required String provinceCode,
    required String cityCode,
    required String districtCode,
    required String postalCode,
    required int courierId,
    required String requiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) async {
    await apiDatasource.createSalesOrder({
      'customerName': customerName,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'shippingAddress': shippingAddress,
      'provinceCode': provinceCode,
      'cityCode': cityCode,
      'districtCode': districtCode,
      'postalCode': postalCode,
      'courierId': courierId,
      'requiredDeliveryDate': requiredDeliveryDate,
      'items': items,
    });
  }

  @override
  Future<void> deleteSalesOrder(int id) async {
    await apiDatasource.deleteSalesOrder(id);
  }
}
