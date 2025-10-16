part of 'cos_cubit.dart';

class CosState extends Equatable {
  const CosState();

  @override
  List<Object> get props => [];
}

class CosInitial extends CosState {}

class RequestingCos extends CosState {}

class RequestingPaginationCos extends CosState {}

class CosData extends CosState {
  final List<dynamic> entities;

  const CosData(this.entities);
}

class CosError extends CosState {
  final String message;

  const CosError(this.message);
}
