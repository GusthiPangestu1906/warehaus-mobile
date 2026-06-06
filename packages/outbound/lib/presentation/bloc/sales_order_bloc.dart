import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outbound/domain/usecases/create_sales_order.dart';
import 'package:outbound/domain/usecases/delete_sales_order.dart';
import 'package:outbound/domain/usecases/get_sales_orders.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';

class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  final GetSalesOrders getSalesOrdersUsecase;
  final CreateSalesOrder createSalesOrderUsecase;
  final DeleteSalesOrder deleteSalesOrderUsecase;

  SalesOrderBloc({
    required this.getSalesOrdersUsecase,
    required this.createSalesOrderUsecase,
    required this.deleteSalesOrderUsecase,
  }) : super(SalesOrderInitial()) {
    on<GetSalesOrdersEvent>((event, emit) async {
      debugPrint('[SalesOrderBloc] GetSalesOrdersEvent');
      emit(SalesOrderLoading());
      try {
        final orders = await getSalesOrdersUsecase();
        debugPrint('[SalesOrderBloc] loaded ${orders.length} orders');
        emit(SalesOrderLoaded(orders));
      } catch (e) {
        debugPrint('[SalesOrderBloc] error: $e');
        emit(SalesOrderError(e.toString()));
      }
    });

    on<CreateSalesOrderEvent>((event, emit) async {
      debugPrint('[SalesOrderBloc] CreateSalesOrderEvent');
      emit(SalesOrderLoading());
      try {
        await createSalesOrderUsecase(
          customerName: event.customerName,
          companyName: event.companyName,
          contactPerson: event.contactPerson,
          phoneNumber: event.phoneNumber,
          shippingAddress: event.shippingAddress,
          provinceCode: event.provinceCode,
          cityCode: event.cityCode,
          districtCode: event.districtCode,
          postalCode: event.postalCode,
          courierId: event.courierId,
          requiredDeliveryDate: event.requiredDeliveryDate,
          items: event.items,
        );
        debugPrint('[SalesOrderBloc] create success');
        emit(SalesOrderActionSuccess('Sales Order berhasil dibuat'));
        add(GetSalesOrdersEvent());
      } catch (e) {
        debugPrint('[SalesOrderBloc] create error: $e');
        emit(SalesOrderError(e.toString()));
      }
    });

    on<DeleteSalesOrderEvent>((event, emit) async {
      debugPrint('[SalesOrderBloc] DeleteSalesOrderEvent id=${event.id}');
      emit(SalesOrderLoading());
      try {
        await deleteSalesOrderUsecase(event.id);
        debugPrint('[SalesOrderBloc] delete success');
        emit(SalesOrderActionSuccess('Sales Order berhasil dihapus'));
        add(GetSalesOrdersEvent());
      } catch (e) {
        debugPrint('[SalesOrderBloc] delete error: $e');
        emit(SalesOrderError(e.toString()));
      }
    });
  }
}
