import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';
import 'package:inbound/data/datasources/purchase_order_api_datasource.dart';
import 'package:inbound/data/models/carrier_model.dart';
import 'package:inbound/data/models/pa_next_item_model.dart';
import 'package:inbound/data/models/purchase_order_model.dart';
import 'package:inbound/data/models/qc_next_item_model.dart';
import 'package:inbound/domain/params/create_po_params.dart';
import 'package:inbound/domain/params/submit_pa_params.dart';
import 'package:inbound/domain/params/submit_qc_params.dart';
import 'package:inbound/domain/repositories/purchase_order_repository.dart';

class PurchaseOrderRepositoryImpl extends PurchaseOrderRepository
    with RepositoryHelper {
  final PurchaseOrderApiDatasource apiDatasource;
  PurchaseOrderRepositoryImpl(this.apiDatasource);

  @override
  Future<Either<Failure, List<PurchaseOrderModel>>> getPurchaseOrders(
    DateTime? date,
  ) {
    return execute(() => apiDatasource.getPurchaseOrders(date));
  }

  @override
  Future<Either<Failure, PurchaseOrderModel>> getPurchaseOrderDetail(int id) {
    return execute(() => apiDatasource.getPurchaseOrderDetail(id));
  }

  @override
  Future<Either<Failure, Unit>> createPurchaseOrder(CreatePoParams params) {
    return execute(() => apiDatasource.createPurchaseOrder(params.toJson()));
  }

  @override
  Future<Either<Failure, Unit>> updatePurchaseOrder(
    int id,
    CreatePoParams params,
  ) {
    return execute(
      () => apiDatasource.updatePurchaseOrder(id, params.toJson()),
    );
  }

  @override
  Future<Either<Failure, Unit>> invoiceUpdate(int id, String invoiceNumber) {
    return execute(() => apiDatasource.invoiceUpdate(id, invoiceNumber));
  }

  @override
  Future<Either<Failure, Unit>> deletePurchaseOrder(int id) {
    return execute(() => apiDatasource.deletePurchaseOrder(id));
  }

  @override
  Future<Either<Failure, List<int>>> downloadPurchaseOrderPdf(int id) {
    return execute(() => apiDatasource.downloadPurchaseOrderPdf(id));
  }

  @override
  Future<Either<Failure, QcNextItemModel>> getQcNextItem(int poId) {
    return execute(() => apiDatasource.getQcNextItem(poId));
  }

  @override
  Future<Either<Failure, Unit>> submitQc(SubmitQcParams params) {
    return execute(() => apiDatasource.submitQc(params.toJson()));
  }

  @override
  Future<Either<Failure, PaNextItemModel>> getPaNextItem(int poId) {
    return execute(() => apiDatasource.getPaNextItem(poId));
  }

  @override
  Future<Either<Failure, Unit>> submitPa(
    SubmitPaParams params,
    int receivingLogId,
  ) {
    return execute(
      () => apiDatasource.submitPa(params.toJson(), receivingLogId),
    );
  }

  @override
  Future<Either<Failure, List<CarrierModel>>> getCarriers() {
    return execute(() => apiDatasource.getCarriers());
  }
}
