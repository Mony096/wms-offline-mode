part of 'purchase_good_receipt_cubit.dart';

class PurchaseGoodReceiptState extends Equatable {
  const PurchaseGoodReceiptState();

  @override
  List<Object> get props => [];
}

class PurchaseGoodReceiptInitial extends PurchaseGoodReceiptState {}

class RequestingPurchaseGoodReceipt extends PurchaseGoodReceiptState {}

class RequestingPaginationPurchaseGoodReceipt
    extends PurchaseGoodReceiptState {}

class PurchaseGoodReceiptData extends PurchaseGoodReceiptState {
  final Map<String, dynamic> entities;

  const PurchaseGoodReceiptData(this.entities);
}

class PurchaseGoodReceiptError extends PurchaseGoodReceiptState {
  final String message;

  const PurchaseGoodReceiptError(this.message);
}
