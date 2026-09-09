import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outbound/domain/entities/sales_order.dart';
import 'package:outbound/domain/params/create_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_params.dart';
import 'package:outbound/domain/params/update_sales_order_tracking_params.dart';
import 'package:outbound/domain/usecases/create_sales_order.dart';
import 'package:outbound/domain/usecases/delete_sales_order.dart';
import 'package:outbound/domain/usecases/get_sales_orders.dart';
import 'package:outbound/domain/usecases/update_sales_order.dart';
import 'package:outbound/domain/usecases/update_sales_order_tracking.dart';
import 'package:outbound/presentation/bloc/sales_order_event.dart';
import 'package:outbound/presentation/bloc/sales_order_state.dart';

class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  final GetSalesOrders getSalesOrdersUsecase;
  final CreateSalesOrder createSalesOrderUsecase;
  final DeleteSalesOrder deleteSalesOrderUsecase;
  final UpdateSalesOrder updateSalesOrderUsecase;
  final UpdateSalesOrderTracking updateSalesOrderTrackingUsecase;

  SalesOrderBloc({
    required this.getSalesOrdersUsecase,
    required this.createSalesOrderUsecase,
    required this.deleteSalesOrderUsecase,
    required this.updateSalesOrderUsecase,
    required this.updateSalesOrderTrackingUsecase,
  }) : super(SalesOrderInitial()) {
    on<GetSalesOrdersEvent>(_onGetSalesOrders);
    on<CreateSalesOrderEvent>(_onCreateSalesOrder);
    on<DeleteSalesOrderEvent>(_onDeleteSalesOrder);
    on<UpdateSalesOrderEvent>(_onUpdateSalesOrder);
    on<UpdateSalesOrderLocalStatusEvent>(_onUpdateSalesOrderLocalStatus);
    on<UpdateSalesOrderTrackingEvent>(_onUpdateSalesOrderTracking);
  }

  Future<void> _onGetSalesOrders(
    GetSalesOrdersEvent event,
    Emitter<SalesOrderState> emit,
  ) async {
    debugPrint('[SalesOrderBloc] GetSalesOrdersEvent date=${event.date}');
    emit(SalesOrderLoading());

    final result = await getSalesOrdersUsecase(date: event.date);

    result.fold(
      (failure) {
        debugPrint('[SalesOrderBloc] error: ${failure.message}');
        emit(SalesOrderError(failure.message));
      },
      (orders) {
        debugPrint('[SalesOrderBloc] loaded ${orders.length} orders');
        emit(SalesOrderLoaded(orders));
      },
    );
  }

  Future<void> _onCreateSalesOrder(
    CreateSalesOrderEvent event,
    Emitter<SalesOrderState> emit,
  ) async {
    debugPrint('[SalesOrderBloc] CreateSalesOrderEvent');
    emit(SalesOrderLoading());

    final result = await createSalesOrderUsecase(
      CreateSalesOrderParams(
        customerName: event.customerName,
        companyName: event.companyName,
        contactPerson: event.contactPerson,
        phoneNumber: event.phoneNumber,
        note: event.note,
        shippingAddress: event.shippingAddress,
        provinceCode: event.provinceCode,
        cityCode: event.cityCode,
        districtCode: event.districtCode,
        postalCode: event.postalCode,
        courierId: event.courierId,
        requiredDeliveryDate: event.requiredDeliveryDate,
        items: event.items,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('[SalesOrderBloc] create error: ${failure.message}');
        emit(SalesOrderError(failure.message));
      },
      (_) {
        debugPrint('[SalesOrderBloc] create success');
        emit(SalesOrderActionSuccess('Sales Order Saved'));
        add(GetSalesOrdersEvent());
      },
    );
  }

  Future<void> _onDeleteSalesOrder(
    DeleteSalesOrderEvent event,
    Emitter<SalesOrderState> emit,
  ) async {
    debugPrint('[SalesOrderBloc] DeleteSalesOrderEvent id=${event.id}');
    emit(SalesOrderLoading());

    final result = await deleteSalesOrderUsecase(event.id);

    result.fold(
      (failure) {
        debugPrint('[SalesOrderBloc] delete error: ${failure.message}');
        emit(SalesOrderError(failure.message));
      },
      (_) {
        debugPrint('[SalesOrderBloc] delete success');
        emit(SalesOrderActionSuccess('Sales Order Deleted'));
        add(GetSalesOrdersEvent());
      },
    );
  }

  Future<void> _onUpdateSalesOrder(
    UpdateSalesOrderEvent event,
    Emitter<SalesOrderState> emit,
  ) async {
    debugPrint('[SalesOrderBloc] UpdateSalesOrderEvent id=${event.id}');
    emit(SalesOrderLoading());

    final result = await updateSalesOrderUsecase(
      UpdateSalesOrderParams(
        id: event.id,
        customerName: event.customerName,
        companyName: event.companyName,
        contactPerson: event.contactPerson,
        phoneNumber: event.phoneNumber,
        note: event.note,
        shippingAddress: event.shippingAddress,
        provinceCode: event.provinceCode,
        cityCode: event.cityCode,
        districtCode: event.districtCode,
        postalCode: event.postalCode,
        courierId: event.courierId,
        requiredDeliveryDate: event.requiredDeliveryDate,
        items: event.items,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('[SalesOrderBloc] update error: ${failure.message}');
        emit(SalesOrderError(failure.message));
      },
      (_) {
        debugPrint('[SalesOrderBloc] update success');
        emit(SalesOrderActionSuccess('Sales Order Saved'));
        add(GetSalesOrdersEvent());
      },
    );
  }

  void _onUpdateSalesOrderLocalStatus(
    UpdateSalesOrderLocalStatusEvent event,
    Emitter<SalesOrderState> emit,
  ) {
    debugPrint(
      '[SalesOrderBloc] UpdateSalesOrderLocalStatusEvent id=${event.id} status=${event.status}',
    );

    final currentState = state;
    if (currentState is! SalesOrderLoaded) return;

    final updatedOrders = _updatedOrders(
      currentState.salesOrders,
      id: event.id,
      status: event.status,
      trackingNumber: event.trackingNumber,
      totalPickedItems: event.totalPickedItems,
      totalVerifiedItems: event.totalVerifiedItems,
      isCompleted: event.isCompleted,
    );

    emit(SalesOrderLoaded(updatedOrders));
  }

  Future<void> _onUpdateSalesOrderTracking(
    UpdateSalesOrderTrackingEvent event,
    Emitter<SalesOrderState> emit,
  ) async {
    debugPrint('[SalesOrderBloc] UpdateSalesOrderTrackingEvent id=${event.id}');

    final currentState = state;
    if (currentState is SalesOrderLoaded) {
      emit(
        SalesOrderLoaded(
          _updatedOrders(
            currentState.salesOrders,
            id: event.id,
            status: 'Active',
            trackingNumber: event.trackingNumber,
          ),
        ),
      );
    }

    final result = await updateSalesOrderTrackingUsecase(
      UpdateSalesOrderTrackingParams(
        id: event.id,
        trackingNumber: event.trackingNumber,
      ),
    );

    result.fold(
      (failure) {
        debugPrint(
          '[SalesOrderBloc] tracking update error: ${failure.message}',
        );
      },
      (_) {
        debugPrint('[SalesOrderBloc] tracking update success');
        add(GetSalesOrdersEvent());
      },
    );
  }

  // --- Helper Methods ---

  List<SalesOrder> _updatedOrders(
    List<SalesOrder> orders, {
    required int id,
    String? status,
    String? trackingNumber,
    int? totalPickedItems,
    int? totalVerifiedItems,
    bool? isCompleted,
  }) {
    return orders.map((order) {
      if (order.id != id) return order;

      return _copyOrder(
        order,
        status: status,
        trackingNumber: trackingNumber ?? order.trackingNumber,
        totalPickedItems: totalPickedItems ?? order.totalPickedItems,
        totalVerifiedItems: totalVerifiedItems ?? order.totalVerifiedItems,
        isCompleted: isCompleted ?? order.isCompleted,
      );
    }).toList();
  }

  SalesOrder _copyOrder(
    SalesOrder order, {
    String? status,
    String? trackingNumber,
    int? totalPickedItems,
    int? totalVerifiedItems,
    bool? isCompleted,
  }) {
    return SalesOrder(
      id: order.id,
      soNumber: order.soNumber,
      customerName: order.customerName,
      companyName: order.companyName,
      contactPerson: order.contactPerson,
      phoneNumber: order.phoneNumber,
      note: order.note,
      shippingAddress: order.shippingAddress,
      provinceCode: order.provinceCode,
      provinceName: order.provinceName,
      cityCode: order.cityCode,
      cityName: order.cityName,
      districtCode: order.districtCode,
      districtName: order.districtName,
      postalCode: order.postalCode,
      courierId: order.courierId,
      courierCode: order.courierCode,
      courierName: order.courierName,
      courierServiceType: order.courierServiceType,
      trackingNumber: trackingNumber,
      requiredDeliveryDate: order.requiredDeliveryDate,
      orderDate: order.orderDate,
      status: status ?? order.status,
      totalOrderedQuantity: order.totalOrderedQuantity,
      totalPickedItems: totalPickedItems ?? order.totalPickedItems,
      totalVerifiedItems: totalVerifiedItems ?? order.totalVerifiedItems,
      progressPercentage: order.progressPercentage,
      isCompleted: isCompleted ?? order.isCompleted,
      items: order.items,
    );
  }
}
