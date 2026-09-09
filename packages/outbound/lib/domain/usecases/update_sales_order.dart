import 'package:dartz/dartz.dart';
import 'package:core_services/core_services.dart';
import 'package:outbound/domain/params/update_sales_order_params.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';

class UpdateSalesOrder {
  final SalesOrderRepository repository;
  const UpdateSalesOrder(this.repository);

  Future<Either<Failure, Unit>> call(UpdateSalesOrderParams params) {
    return repository.updateSalesOrder(params);
  }
}
