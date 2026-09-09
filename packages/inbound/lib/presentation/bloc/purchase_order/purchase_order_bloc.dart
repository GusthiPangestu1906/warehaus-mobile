import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/usecases/purchase_order/create_purchase_order.dart';
import 'package:inbound/domain/usecases/purchase_order/delete_purchase_order.dart';
import 'package:inbound/domain/usecases/purchase_order/download_purchase_order_pdf.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_order_detail.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_orders.dart';
import 'package:inbound/domain/usecases/purchase_order/invoice_update.dart';
import 'package:inbound/domain/usecases/purchase_order/update_purchase_order.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';

class PurchaseOrderBloc extends Bloc<PurchaseOrderEvent, PurchaseOrderState> {
  final CreatePurchaseOrder createPurchaseOrderUsecase;
  final GetPurchaseOrderDetail getPurchaseOrderDetailUsecase;
  final GetPurchaseOrders getPurchaseOrdersUsecase;
  final UpdatePurchaseOrder updatePurchaseOrderUsecase;
  final InvoiceUpdate invoiceUpdateUsecase;
  final DeletePurchaseOrder deletePurchaseOrderUsecase;
  final DownloadPurchaseOrderPdf downloadPurchaseOrderPdfUsecase;

  PurchaseOrderBloc({
    required this.createPurchaseOrderUsecase,
    required this.getPurchaseOrderDetailUsecase,
    required this.getPurchaseOrdersUsecase,
    required this.updatePurchaseOrderUsecase,
    required this.invoiceUpdateUsecase,
    required this.deletePurchaseOrderUsecase,
    required this.downloadPurchaseOrderPdfUsecase,
  }) : super(PurchaseOrderInitial()) {
    on<GetPurchaseOrdersEvent>(_onGetPurchaseOrders);
    on<GetPurchaseOrderDetailEvent>(_onGetPurchaseOrderDetail);
    on<UpdateInvoiceEvent>(_onUpdateInvoice);
    on<CreatePurchaseOrderEvent>(_onCreatePurchaseOrder);
    on<UpdatePurchaseOrderEvent>(_onUpdatePurchaseOrder);
    on<DeletePurchaseOrderEvent>(_onDeletePurchaseOrder);
    on<DownloadPurchaseOrderPdfEvent>(_onDownloadPurchaseOrderPdf);
  }

  Future<void> _onGetPurchaseOrders(
    GetPurchaseOrdersEvent event,
    Emitter<PurchaseOrderState> emit,
  ) async {
    emit(PurchaseOrderLoading());
    final result = await getPurchaseOrdersUsecase(date: event.date);
    result.fold(
      (failure) => emit(PurchaseOrderError(failure.message)),
      (purchaseOrders) => emit(PurchaseOrderLoaded(purchaseOrders)),
    );
  }

  Future<void> _onGetPurchaseOrderDetail(
    GetPurchaseOrderDetailEvent event,
    Emitter<PurchaseOrderState> emit,
  ) async {
    emit(PurchaseOrderLoading());
    final result = await getPurchaseOrderDetailUsecase(event.id);
    result.fold(
      (failure) => emit(PurchaseOrderError(failure.message)),
      (purchaseOrder) => emit(PurchaseOrderDetailLoaded(purchaseOrder)),
    );
  }

  Future<void> _onUpdateInvoice(
    UpdateInvoiceEvent event,
    Emitter<PurchaseOrderState> emit,
  ) async {
    emit(PurchaseOrderLoading());
    final result = await invoiceUpdateUsecase(event.id, event.invoiceNumber);
    result.fold(
      (failure) => emit(PurchaseOrderError(failure.message)),
      (_) => emit(UpdateInvoiceSuccess()),
    );
  }

  Future<void> _onCreatePurchaseOrder(
    CreatePurchaseOrderEvent event,
    Emitter<PurchaseOrderState> emit,
  ) async {
    emit(PurchaseOrderLoading());
    final result = await createPurchaseOrderUsecase(event.params);
    result.fold(
      (failure) => emit(PurchaseOrderError(failure.message)),
      (_) => emit(CreatePurchaseOrderSuccess()),
    );
  }

  Future<void> _onUpdatePurchaseOrder(
    UpdatePurchaseOrderEvent event,
    Emitter<PurchaseOrderState> emit,
  ) async {
    emit(PurchaseOrderLoading());
    final result = await updatePurchaseOrderUsecase(event.id, event.params);
    result.fold(
      (failure) => emit(PurchaseOrderError(failure.message)),
      (_) => emit(UpdatePurchaseOrderSuccess()),
    );
  }

  Future<void> _onDeletePurchaseOrder(
    DeletePurchaseOrderEvent event,
    Emitter<PurchaseOrderState> emit,
  ) async {
    emit(PurchaseOrderLoading());
    final result = await deletePurchaseOrderUsecase(event.id);
    result.fold(
      (failure) => emit(PurchaseOrderError(failure.message)),
      (_) => emit(DeletePurchaseOrderSuccess()),
    );
  }

  Future<void> _onDownloadPurchaseOrderPdf(
    DownloadPurchaseOrderPdfEvent event,
    Emitter<PurchaseOrderState> emit,
  ) async {
    final result = await downloadPurchaseOrderPdfUsecase(
      event.id,
      event.poNumber,
    );
    result.fold(
      (failure) => emit(PurchaseOrderActionError(failure.message)),
      (filePath) => emit(DownloadPurchaseOrderPdfSuccess(filePath)),
    );
  }
}
