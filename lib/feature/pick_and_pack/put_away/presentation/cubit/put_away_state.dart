part of 'put_away_cubit.dart';

class PutAwayState extends Equatable {
  const PutAwayState();

  @override
  List<Object> get props => [];
}

class PutAwayInitial extends PutAwayState {}

class RequestingPutAway extends PutAwayState {}

class RequestingPaginationPutAway extends PutAwayState {}

class PutAwayData extends PutAwayState {
  final Map<String, dynamic> entities;

  const PutAwayData(this.entities);
}

class PutAwayError extends PutAwayState {
  final String message;

  const PutAwayError(this.message);
}
