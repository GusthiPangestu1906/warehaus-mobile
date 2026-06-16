import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';

class GetSalesOrders {
  final SalesOrderRepository repository;
  const GetSalesOrders(this.repository);
  Future<List<SalesOrder>> call({String? date}) =>
      repository.getSalesOrders(date: date);
}
