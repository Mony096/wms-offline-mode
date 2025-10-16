part of 'grt_cubit.dart';

class GoodIssueSelectState extends Equatable {
  const GoodIssueSelectState();

  @override
  List<Object> get props => [];
}

class GoodIssueSelectInitial extends GoodIssueSelectState {}

class RequestingGoodIssueSelect extends GoodIssueSelectState {}

class RequestingPaginationGoodIssueSelect extends GoodIssueSelectState {}

class GoodIssueSelectData extends GoodIssueSelectState {
  final List<GoodIssueSelectEntity> entities;

  const GoodIssueSelectData(this.entities);
}

class GoodIssueSelectError extends GoodIssueSelectState {
  final String message;

  const GoodIssueSelectError(this.message);
}
