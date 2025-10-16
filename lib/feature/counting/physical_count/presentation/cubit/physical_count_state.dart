part of 'physical_count_cubit.dart';

class PhysicalCountState extends Equatable {
  const PhysicalCountState();

  @override
  List<Object> get props => [];
}

class PhysicalCountInitial extends PhysicalCountState {}

class RequestingPhysicalCount extends PhysicalCountState {}

class RequestingPaginationPhysicalCount extends PhysicalCountState {}

class PhysicalCountData extends PhysicalCountState {
  final Map<String, dynamic> entities;

  const PhysicalCountData(this.entities);
}

class PhysicalCountError extends PhysicalCountState {
  final String message;

  const PhysicalCountError(this.message);
}
