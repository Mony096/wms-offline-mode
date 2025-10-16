part of 'binlocation_count_cubit.dart';

class BinlocationCountState extends Equatable {
  const BinlocationCountState();

  @override
  List<Object> get props => [];
}

class BinlocationCountInitial extends BinlocationCountState {}

class RequestingBinlocationCount extends BinlocationCountState {}

class RequestingPaginationBinlocationCount extends BinlocationCountState {}

class BinlocationCountData extends BinlocationCountState {
  final Map<String, dynamic> entities;

  const BinlocationCountData(this.entities);
}

class BinlocationCountError extends BinlocationCountState {
  final String message;

  const BinlocationCountError(this.message);
}
