import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class InvoiceUpdate {
  final PurchaseOrderRepository repository;
  InvoiceUpdate({required this.repository});

  Future<Either<Failure, void>> call(int id, String invoiceNumber) async {
    return await repository.invoiceUpdate(id, invoiceNumber);
  }
}
