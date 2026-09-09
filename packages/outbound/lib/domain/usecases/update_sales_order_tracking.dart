import 'package:dartz/dartz.dart';
import 'package:core_services/core_services.dart';
import 'package:outbound/domain/params/update_sales_order_tracking_params.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';

class UpdateSalesOrderTracking {
  final SalesOrderRepository repository;
  const UpdateSalesOrderTracking(this.repository);

  Future<Either<Failure, Unit>> call(UpdateSalesOrderTrackingParams params) {
    return repository.updateTrackingNumber(params);
  }
}
