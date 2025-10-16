part of 'purchase_order_cubit.dart';

class PurchaseOrderState extends Equatable {
  const PurchaseOrderState();

  @override
  List<Object> get props => [];
}

class PurchaseOrderInitial extends PurchaseOrderState {}

class RequestingPurchaseOrder extends PurchaseOrderState {}

class RequestingPaginationPurchaseOrder extends PurchaseOrderState {}

class PurchaseOrderData extends PurchaseOrderState {
  final List<dynamic> entities;

  const PurchaseOrderData(this.entities);
}

class PurchaseOrderError extends PurchaseOrderState {
  final String message;

  const PurchaseOrderError(this.message);
}
