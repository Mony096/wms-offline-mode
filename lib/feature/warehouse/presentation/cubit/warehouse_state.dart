part of 'warehouse_cubit.dart';

class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class RequestingWarehouse extends WarehouseState {}

class RequestingPaginationWarehouse extends WarehouseState {}

class WarehouseData extends WarehouseState {
  final List<WarehouseEntity> entities;

  const WarehouseData(this.entities);
}

class WarehouseError extends WarehouseState {
  final String message;

  const WarehouseError(this.message);
}
