import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteSalesOrder {
  final SalesOrderRepository repository;
  const DeleteSalesOrder(this.repository);

  Future<Either<Failure, Unit>> call(int id) => repository.deleteSalesOrder(id);
}
