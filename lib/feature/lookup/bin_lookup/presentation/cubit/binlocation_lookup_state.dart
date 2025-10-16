part of 'binlocation_lookup_cubit.dart';

class BinLookUpState extends Equatable {
  const BinLookUpState();

  @override
  List<Object> get props => [];
}

class BinLookUpInitial extends BinLookUpState {}

class RequestingBinLookUp extends BinLookUpState {}

class RequestingPaginationBinLookUp extends BinLookUpState {}

class BinLookUpData extends BinLookUpState {
  final Map<String, dynamic> entities;

  const BinLookUpData(this.entities);
}

class BinLookUpError extends BinLookUpState {
  final String message;

  const BinLookUpError(this.message);
}
