import 'package:outbound/domain/params/update_sales_order_params.dart';
import 'package:outbound/domain/repositories/sales_order_repository.dart';

class UpdateSalesOrder {
  final SalesOrderRepository repository;
  const UpdateSalesOrder(this.repository);

  Future<void> call(UpdateSalesOrderParams params) {
    return repository.updateSalesOrder(params);
  }
}
