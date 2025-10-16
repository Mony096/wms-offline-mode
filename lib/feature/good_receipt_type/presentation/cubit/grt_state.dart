part of 'grt_cubit.dart';

class GrtState extends Equatable {
  const GrtState();

  @override
  List<Object> get props => [];
}

class GrtInitial extends GrtState {}

class RequestingGrt extends GrtState {}

class RequestingPaginationGrt extends GrtState {}

class GrtData extends GrtState {
  final List<GrtEntity> entities;

  const GrtData(this.entities);
}

class GrtError extends GrtState {
  final String message;

  const GrtError(this.message);
}
