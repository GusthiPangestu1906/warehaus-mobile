import 'package:outbound/domain/repositories/sales_order_repository.dart';

class UpdateSalesOrderTracking {
  final SalesOrderRepository repository;
  const UpdateSalesOrderTracking(this.repository);

  Future<void> call(int id, String trackingNumber) {
    return repository.updateTrackingNumber(id, trackingNumber);
  }
}
