import 'package:core_services/helpers/repository_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:outbound/data/datasources/sales_order_api_datasource.dart';
import 'package:outbound/data/models/sales_order_model.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_tracking_params.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';
import 'package:core_services/error/failure.dart';

class SalesOrderRepositoryImpl extends SalesOrderRepository
    with RepositoryHelper {
  final SalesOrderApiDatasource apiDatasource;

  SalesOrderRepositoryImpl(this.apiDatasource);

  @override
  Future<Either<Failure, List<SalesOrder>>> getSalesOrders({String? date}) {
    return execute(() async {
      final list = await apiDatasource.getSalesOrders(date: date);
      return list.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, SalesOrder>> getSalesOrderById(int id) {
    return execute(() async {
      final model = await apiDatasource.getSalesOrderById(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> createSalesOrder(
    CreateSalesOrderParams params,
  ) {
    return execute(() async {
      await apiDatasource.createSalesOrder(params.toJson());
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> updateSalesOrder(
    UpdateSalesOrderParams params,
  ) {
    return execute(() async {
      await apiDatasource.updateSalesOrder(params.id, params.toJson());
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteSalesOrder(int id) {
    return execute(() async {
      await apiDatasource.deleteSalesOrder(id);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> updateTrackingNumber(
    UpdateSalesOrderTrackingParams params,
  ) {
    return execute(() async {
      await apiDatasource.updateTrackingNumber(
        params.id,
        params.trackingNumber,
      );
      return unit;
    });
  }
}
