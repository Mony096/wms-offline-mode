part of 'return_receipt_cubit.dart';

class ReturnReceiptState extends Equatable {
  const ReturnReceiptState();

  @override
  List<Object> get props => [];
}

class ReturnReceiptInitial extends ReturnReceiptState {}

class RequestingReturnReceipt extends ReturnReceiptState {}

class RequestingPaginationReturnReceipt extends ReturnReceiptState {}

class ReturnReceiptData extends ReturnReceiptState {
  final Map<String, dynamic> entities;

  const ReturnReceiptData(this.entities);
}

class ReturnReceiptError extends ReturnReceiptState {
  final String message;

  const ReturnReceiptError(this.message);
}
