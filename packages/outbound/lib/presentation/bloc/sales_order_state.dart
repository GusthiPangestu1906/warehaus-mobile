import 'package:outbound/domain/entities/sales_order.dart';

abstract class SalesOrderState {}

class SalesOrderInitial extends SalesOrderState {}

class SalesOrderLoading extends SalesOrderState {}

class SalesOrderLoaded extends SalesOrderState {
  final List<SalesOrder> salesOrders;
  SalesOrderLoaded(this.salesOrders);
}

class SalesOrderActionSuccess extends SalesOrderState {
  final String message;
  SalesOrderActionSuccess(this.message);
}

class SalesOrderError extends SalesOrderState {
  final String message;
  SalesOrderError(this.message);
}
