import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_tracking_params.dart';

abstract class SalesOrderRepository {
  Future<Either<Failure, List<SalesOrder>>> getSalesOrders({String? date});
  Future<Either<Failure, SalesOrder>> getSalesOrderById(int id);
  Future<Either<Failure, Unit>> createSalesOrder(CreateSalesOrderParams params);
  Future<Either<Failure, Unit>> updateSalesOrder(UpdateSalesOrderParams params);
  Future<Either<Failure, Unit>> deleteSalesOrder(int id);
  Future<Either<Failure, Unit>> updateTrackingNumber(
    UpdateSalesOrderTrackingParams params,
  );
}
