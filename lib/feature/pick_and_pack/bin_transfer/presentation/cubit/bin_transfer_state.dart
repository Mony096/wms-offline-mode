part of 'bin_transfer_cubit.dart';

class BinTransferState extends Equatable {
  const BinTransferState();

  @override
  List<Object> get props => [];
}

class BinTransferInitial extends BinTransferState {}

class RequestingBinTransfer extends BinTransferState {}

class RequestingPaginationBinTransfer extends BinTransferState {}

class BinTransferData extends BinTransferState {
  final Map<String, dynamic> entities;

  const BinTransferData(this.entities);
}

class BinTransferError extends BinTransferState {
  final String message;

  const BinTransferError(this.message);
}
