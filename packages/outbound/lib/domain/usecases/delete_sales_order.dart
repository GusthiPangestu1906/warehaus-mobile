import 'package:outbound/domain/repositories/sales_order_repository.dart';

class DeleteSalesOrder {
  final SalesOrderRepository repository;
  const DeleteSalesOrder(this.repository);
  Future<void> call(int id) => repository.deleteSalesOrder(id);
}
