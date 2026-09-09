import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/domain/entities/carrier.dart';
import 'package:inbound/domain/entities/pa_next_item.dart';
import 'package:inbound/domain/entities/purchase_order.dart';
import 'package:inbound/domain/entities/qc_next_item.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/domain/params/submit_qc_params.dart';

abstract class PurchaseOrderRepository {
  Future<Either<Failure, List<PurchaseOrder>>> getPurchaseOrders(
    DateTime? date,
  );
  Future<Either<Failure, PurchaseOrder>> getPurchaseOrderDetail(int id);
  Future<Either<Failure, Unit>> createPurchaseOrder(CreatePoParams params);
  Future<Either<Failure, Unit>> updatePurchaseOrder(
    int id,
    CreatePoParams params,
  );
  Future<Either<Failure, Unit>> invoiceUpdate(int id, String invoiceNumber);
  Future<Either<Failure, Unit>> deletePurchaseOrder(int id);
  Future<Either<Failure, List<int>>> downloadPurchaseOrderPdf(int id);
  Future<Either<Failure, QcNextItem>> getQcNextItem(int poId);
  Future<Either<Failure, Unit>> submitQc(SubmitQcParams params);
  Future<Either<Failure, PaNextItem>> getPaNextItem(int poId);
  Future<Either<Failure, Unit>> submitPa(
    SubmitPaParams params,
    int receivingLogId,
  );
  Future<Either<Failure, List<Carrier>>> getCarriers();
}
