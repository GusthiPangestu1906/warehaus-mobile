import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inbound/domain/usecases/purchase_order/create_purchase_order.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_event.dart';
import 'package:inbound/presentation/bloc/purchase_order/purchase_order_state.dart';

class PurchaseOrderBloc extends Bloc<PurchaseOrderEvent, PurchaseOrderState> {
  final CreatePurchaseOrder createPurchaseOrderUsecase;

  PurchaseOrderBloc({required this.createPurchaseOrderUsecase})
    : super(PurchaseOrderInitial()) {
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
