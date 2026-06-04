import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/usecases/purchase_order/create_purchase_order.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_order_detail.dart';
import 'package:inbound/domain/usecases/purchase_order/get_purchase_orders.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';

class PurchaseOrderBloc extends Bloc<PurchaseOrderEvent, PurchaseOrderState> {
  final CreatePurchaseOrder createPurchaseOrderUsecase;
  final GetPurchaseOrderDetail getPurchaseOrderDetailUsecase;
  final GetPurchaseOrders getPurchaseOrdersUsecase;

  PurchaseOrderBloc({
    required this.createPurchaseOrderUsecase,
    required this.getPurchaseOrderDetailUsecase,
    required this.getPurchaseOrdersUsecase,
  }) : super(PurchaseOrderInitial()) {
    on<GetPurchaseOrdersEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      try {
        final purchaseOrders = await getPurchaseOrdersUsecase();
        emit(PurchaseOrderLoaded(purchaseOrders));
      } catch (e) {
        emit(PurchaseOrderError(e.toString()));
      }
    });
    on<GetPurchaseOrderDetailEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      try {
        final purchaseOrder = await getPurchaseOrderDetailUsecase(event.id);
        emit(PurchaseOrderDetailLoaded(purchaseOrder));
      } catch (e) {
        emit(PurchaseOrderError(e.toString()));
      }
    });
    on<CreatePurchaseOrderEvent>((event, emit) async {
      emit(PurchaseOrderLoading());
      try {
        await createPurchaseOrderUsecase(event.params);
        emit(CreatePurchaseOrderSuccess());
      } catch (e) {
        emit(PurchaseOrderError(e.toString()));
      }
    });
  }
}
