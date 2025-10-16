part of 'batch_list_cubit.dart';

class  BatchListState extends Equatable {
  const BatchListState();

  @override
  List<Object> get props => [];
}

class BinInitial extends  BatchListState {}

class RequestingBin extends  BatchListState {}

class RequestingPaginationBin extends  BatchListState {}

class BinData extends  BatchListState {
  final List<dynamic> entities;

  const BinData(this.entities);
}

class BinError extends  BatchListState {
  final String message;

  const BinError(this.message);
}
