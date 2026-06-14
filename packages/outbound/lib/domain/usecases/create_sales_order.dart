import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';

class CreateSalesOrder {
  final SalesOrderRepository repository;
  const CreateSalesOrder(this.repository);

  Future<void> call(CreateSalesOrderParams params) {
    return repository.createSalesOrder(params);
  }
}
