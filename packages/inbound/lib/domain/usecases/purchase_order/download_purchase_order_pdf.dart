import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class DownloadPurchaseOrderPdf {
  const DownloadPurchaseOrderPdf(this.repository);

  final PurchaseOrderRepository repository;

  Future<Either<Failure, String>> call(int id, String poNumber) {
    return repository.downloadPurchaseOrderPdf(id, poNumber);
  }
}
