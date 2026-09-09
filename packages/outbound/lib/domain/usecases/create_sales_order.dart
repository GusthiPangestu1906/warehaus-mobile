import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';
import 'package:dartz/dartz.dart';

class CreateSalesOrder {
  final SalesOrderRepository repository;
  const CreateSalesOrder(this.repository);

  Future<Either<Failure, Unit>> call(CreateSalesOrderParams params) {
    return repository.createSalesOrder(params);
  }
}
