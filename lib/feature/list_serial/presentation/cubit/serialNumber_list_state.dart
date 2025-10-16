part of 'serialNumber_list_cubit.dart';

class  SerialListState extends Equatable {
  const SerialListState();

  @override
  List<Object> get props => [];
}

class BinInitial extends  SerialListState {}

class RequestingBin extends  SerialListState {}

class RequestingPaginationBin extends  SerialListState {}

class BinData extends  SerialListState {
  final List<dynamic> entities;

  const BinData(this.entities);
}

class BinError extends  SerialListState {
  final String message;

  const BinError(this.message);
}
