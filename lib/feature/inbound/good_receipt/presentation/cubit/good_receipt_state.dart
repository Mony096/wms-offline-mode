part of 'good_receipt_cubit.dart';

class GoodReceiptState extends Equatable {
  const GoodReceiptState();

  @override
  List<Object> get props => [];
}

class GoodReceiptInitial extends GoodReceiptState {}

class RequestingGoodReceipt extends GoodReceiptState {}

class RequestingPaginationGoodReceipt extends GoodReceiptState {}

class GoodReceiptData extends GoodReceiptState {
  final Map<String, dynamic> entities;

  const GoodReceiptData(this.entities);
}

class GoodReceiptError extends GoodReceiptState {
  final String message;

  const GoodReceiptError(this.message);
}
