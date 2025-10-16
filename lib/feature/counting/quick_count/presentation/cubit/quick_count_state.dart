part of 'quick_count_cubit.dart';

class QuickCountState extends Equatable {
  const QuickCountState();

  @override
  List<Object> get props => [];
}

class QuickCountInitial extends QuickCountState {}

class RequestingQuickCount extends QuickCountState {}

class RequestingPaginationQuickCount extends QuickCountState {}

class QuickCountData extends QuickCountState {
  final Map<String, dynamic> entities;

  const QuickCountData(this.entities);
}

class QuickCountError extends QuickCountState {
  final String message;

  const QuickCountError(this.message);
}
