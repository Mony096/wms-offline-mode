part of 'purchase_return_cubit.dart';

class PurchaseReturnState extends Equatable {
  const PurchaseReturnState();

  @override
  List<Object> get props => [];
}

class PurchaseReturnInitial extends PurchaseReturnState {}

class RequestingPurchaseReturn extends PurchaseReturnState {}

class RequestingPaginationPurchaseReturn extends PurchaseReturnState {}

class PurchaseReturnData extends PurchaseReturnState {
  final Map<String, dynamic> entities;

  const PurchaseReturnData(this.entities);
}

class PurchaseReturnError extends PurchaseReturnState {
  final String message;

  const PurchaseReturnError(this.message);
}
