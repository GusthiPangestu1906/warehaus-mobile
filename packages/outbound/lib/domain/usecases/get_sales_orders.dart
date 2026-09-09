import 'package:core_services/error/failure.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';
import 'package:dartz/dartz.dart';

class GetSalesOrders {
  final SalesOrderRepository repository;
  const GetSalesOrders(this.repository);

  Future<Either<Failure, List<SalesOrder>>> call({String? date}) =>
      repository.getSalesOrders(date: date);
}
