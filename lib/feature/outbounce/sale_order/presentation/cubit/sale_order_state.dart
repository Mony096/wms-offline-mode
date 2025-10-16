part of 'sale_order_cubit.dart';

class SaleOrderState extends Equatable {
  const SaleOrderState();

  @override
  List<Object> get props => [];
}

class SaleOrderInitial extends SaleOrderState {}

class RequestingSaleOrder extends SaleOrderState {}

class RequestingPaginationSaleOrder extends SaleOrderState {}

class SaleOrderData extends SaleOrderState {
  final List<dynamic> entities;

  const SaleOrderData(this.entities);
}

class SaleOrderError extends SaleOrderState {
  final String message;

  const SaleOrderError(this.message);
}
