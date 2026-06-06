import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class InvoiceUpdate {
  final PurchaseOrderRepository repository;
  InvoiceUpdate({required this.repository});

  Future<void> call(int id, String invoiceNumber) async {
    return await repository.invoiceUpdate(id, invoiceNumber);
  }
}
