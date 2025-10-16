part of 'return_receipt_request_cubit.dart';

class ReturnReceiptRequestState extends Equatable {
  const ReturnReceiptRequestState();

  @override
  List<Object> get props => [];
}

class ReturnReceiptRequestInitial extends ReturnReceiptRequestState {}

class RequestingReturnReceiptRequest extends ReturnReceiptRequestState {}

class RequestingPaginationReturnReceiptRequest
    extends ReturnReceiptRequestState {}

class ReturnReceiptRequestData extends ReturnReceiptRequestState {
  final List<dynamic> entities;

  const ReturnReceiptRequestData(this.entities);
}

class ReturnReceiptRequestError extends ReturnReceiptRequestState {
  final String message;

  const ReturnReceiptRequestError(this.message);
}
