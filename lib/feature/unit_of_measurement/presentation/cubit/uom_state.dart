part of 'uom_cubit.dart';

class UnitOfMeasurementState extends Equatable {
  const UnitOfMeasurementState();

  @override
  List<Object> get props => [];
}

class UnitOfMeasurementInitial extends UnitOfMeasurementState {}

class RequestingUnitOfMeasurement extends UnitOfMeasurementState {}

class RequestingPaginationUnitOfMeasurement extends UnitOfMeasurementState {}

class UnitOfMeasurementData extends UnitOfMeasurementState {
  final List<UnitOfMeasurementEntity> entities;

  const UnitOfMeasurementData(this.entities);
}

class UnitOfMeasurementError extends UnitOfMeasurementState {
  final String message;

  const UnitOfMeasurementError(this.message);
}
