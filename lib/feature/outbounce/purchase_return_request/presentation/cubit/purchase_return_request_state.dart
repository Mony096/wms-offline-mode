part of 'purchase_return_request_cubit.dart';

class PurchaseReturnRequestState extends Equatable {
  const PurchaseReturnRequestState();

  @override
  List<Object> get props => [];
}

class PurchaseReturnRequestInitial extends PurchaseReturnRequestState {}

class RequestingPurchaseReturnRequest extends PurchaseReturnRequestState {}

class RequestingPaginationPurchaseReturnRequest
    extends PurchaseReturnRequestState {}

class PurchaseReturnRequestData extends PurchaseReturnRequestState {
  final List<dynamic> entities;

  const PurchaseReturnRequestData(this.entities);
}

class PurchaseReturnRequestError extends PurchaseReturnRequestState {
  final String message;

  const PurchaseReturnRequestError(this.message);
}
