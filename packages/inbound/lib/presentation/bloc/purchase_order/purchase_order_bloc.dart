import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/usecases/inbound/get_pa_next_item.dart';
import 'package:inbound/domain/usecases/inbound/get_qc_next_item.dart';
import 'package:inbound/domain/usecases/inbound/submit_pa.dart';
import 'package:inbound/domain/usecases/inbound/submit_qc.dart';
import 'package:inbound/domain/usecases/purchase_order/create_purchase_order.dart';
import 'package:inbound/domain/usecases/purchase_order/delete_purchase_order.dart';
import 'package:inbound/domain/usecases/purchase_order/download_purchase_order_pdf.dart';
import 'package:inbound/domain/usecases/purchase_order/get_carriers.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_order_detail.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_orders.dart';
import 'package:inbound/domain/usecases/purchase_order/invoice_update.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';

class PurchaseOrderBloc extends Bloc<PurchaseOrderEvent, PurchaseOrderState> {
  final CreatePurchaseOrder createPurchaseOrderUsecase;
  final GetPurchaseOrderDetail getPurchaseOrderDetailUsecase;
  final GetPurchaseOrders getPurchaseOrdersUsecase;
  final InvoiceUpdate invoiceUpdateUsecase;
  final DeletePurchaseOrder deletePurchaseOrderUsecase;
  final DownloadPurchaseOrderPdf downloadPurchaseOrderPdfUsecase;
  final GetQcNextItem getQcNextItemUsecase;
  final SubmitQc submitQcUsecase;
  final GetPaNextItem getPaNextItem;
  final SubmitPa submitPaUsecase;
  final GetCarriers getCarriers;

  PurchaseOrderBloc({
    required this.createPurchaseOrderUsecase,
    required this.getPurchaseOrderDetailUsecase,
    required this.getPurchaseOrdersUsecase,
    required this.invoiceUpdateUsecase,
    required this.deletePurchaseOrderUsecase,
    required this.downloadPurchaseOrderPdfUsecase,
    required this.getQcNextItemUsecase,
    required this.submitQcUsecase,
    required this.getPaNextItem,
    required this.submitPaUsecase,
    required this.getCarriers,
  }) : super(PurchaseOrderInitial()) {
    on<GetPurchaseOrdersEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await getPurchaseOrdersUsecase();
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (purchaseOrders) => emit(PurchaseOrderLoaded(purchaseOrders)),
      );
    });
    on<GetPurchaseOrderDetailEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await getPurchaseOrderDetailUsecase(event.id);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (purchaseOrder) => emit(PurchaseOrderDetailLoaded(purchaseOrder)),
      );
    });
    on<UpdateInvoiceEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await invoiceUpdateUsecase(event.id, event.invoiceNumber);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (_) => emit(UpdateInvoiceSuccess()),
      );
    });
    on<CreatePurchaseOrderEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await createPurchaseOrderUsecase(event.params);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (_) => emit(CreatePurchaseOrderSuccess()),
      );
    });
    on<DeletePurchaseOrderEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await deletePurchaseOrderUsecase(event.id);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (_) => emit(DeletePurchaseOrderSuccess()),
      );
    });
    on<DownloadPurchaseOrderPdfEvent>((event, emit) async {
      final currentState = state;
      final result = await downloadPurchaseOrderPdfUsecase(
        event.id,
        event.poNumber,
      );
      result.fold(
        (failure) => emit(PurchaseOrderActionError(failure.message)),
        (filePath) => emit(DownloadPurchaseOrderPdfSuccess(filePath)),
      );
      if (currentState is PurchaseOrderDetailLoaded) {
        emit(currentState);
      }
    });
    on<GetQcNextItemEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await getQcNextItemUsecase(event.poId);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (item) => emit(QcNextItemLoaded(item)),
      );
    });
    on<SubmitQcEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await submitQcUsecase(event.params);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (_) => emit(SubmitQcSuccess()),
      );
    });
    on<GetPaNextItemEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await getPaNextItem(event.poId);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (item) => emit(PaNextItemLoaded(item)),
      );
    });
    on<SubmitPaEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await submitPaUsecase(event.params, event.receivingLogId);
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (_) => emit(SubmitPaSuccess()),
      );
    });
    on<GetCarriersEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      final result = await getCarriers();
      result.fold(
        (failure) => emit(PurchaseOrderError(failure.message)),
        (carriers) => emit(CarriersLoaded(carriers)),
      );
    });
  }
}
