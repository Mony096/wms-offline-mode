part of 'warehouse_transfer_cubit.dart';

class WarehouseTransferState extends Equatable {
  const WarehouseTransferState();

  @override
  List<Object> get props => [];
}

class WarehouseTransferInitial extends WarehouseTransferState {}

class RequestingWarehouseTransfer extends WarehouseTransferState {}

class RequestingPaginationWarehouseTransfer extends WarehouseTransferState {}

class WarehouseTransferData extends WarehouseTransferState {
  final Map<String, dynamic> entities;

  const WarehouseTransferData(this.entities);
}

class WarehouseTransferError extends WarehouseTransferState {
  final String message;

  const WarehouseTransferError(this.message);
}
