part of 'bin_cubit.dart';

class BinState extends Equatable {
  const BinState();

  @override
  List<Object> get props => [];
}

class BinInitial extends BinState {}

class RequestingBin extends BinState {}

class RequestingPaginationBin extends BinState {}

class BinData extends BinState {
  final List<BinEntity> entities;

  const BinData(this.entities);
}

class BinError extends BinState {
  final String message;

  const BinError(this.message);
}
