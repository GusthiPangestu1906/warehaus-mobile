import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/data/models/sales_order_model.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/entities/so_item.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_tracking_params.dart';
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
    note: m.note,
    shippingAddress: m.shippingAddress,
    provinceCode: m.provinceCode,
    provinceName: m.provinceName,
    cityCode: m.cityCode,
    cityName: m.cityName,
    districtCode: m.districtCode,
    districtName: m.districtName,
    postalCode: m.postalCode,
    courierId: m.courierId,
    courierCode: m.courierCode,
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
            id: e.id,
            productId: e.productId,
            qtyOrdered: e.qtyOrdered,
            productName: e.productName,
            sku: e.sku,
            barcode: e.barcode,
            unitOfMeasure: e.unitOfMeasure,
            qtyPicked: e.qtyPicked,
            qtyVerified: e.qtyVerified,
            suggestedLocations: e.suggestedLocations
                .map(
                  (location) => SoItemSuggestedLocation(
                    shelfId: location.shelfId,
                    shelfCode: location.shelfCode,
                    zoneCode: location.zoneCode,
                    zoneName: location.zoneName,
                    aisle: location.aisle,
                    availableQuantity: location.availableQuantity,
                  ),
                )
                .toList(),
          ),
        )
        .toList(),
  );

  @override
  Future<List<SalesOrder>> getSalesOrders({String? date}) async {
    final list = await apiDatasource.getSalesOrders(date: date);
    return list.map(_toEntity).toList();
  }

  @override
  Future<SalesOrder> getSalesOrderById(int id) async {
    final model = await apiDatasource.getSalesOrderById(id);
    return _toEntity(model);
  }

  @override
  Future<void> createSalesOrder(CreateSalesOrderParams params) async {
    await apiDatasource.createSalesOrder(params.toJson());
  }

  @override
  Future<void> updateSalesOrder(UpdateSalesOrderParams params) async {
    await apiDatasource.updateSalesOrder(params.id, params.toJson());
  }

  @override
  Future<void> deleteSalesOrder(int id) async {
    await apiDatasource.deleteSalesOrder(id);
  }

  @override
  Future<void> updateTrackingNumber(
    UpdateSalesOrderTrackingParams params,
  ) async {
    await apiDatasource.updateTrackingNumber(params.id, params.trackingNumber);
  }
}
