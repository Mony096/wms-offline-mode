part of 'good_issue_cubit.dart';

class GoodIssueState extends Equatable {
  const GoodIssueState();

  @override
  List<Object> get props => [];
}

class GoodIssueInitial extends GoodIssueState {}

class RequestingGoodIssue extends GoodIssueState {}

class RequestingPaginationGoodIssue extends GoodIssueState {}

class GoodIssueData extends GoodIssueState {
  final Map<String, dynamic> entities;

  const GoodIssueData(this.entities);
}

class GoodIssueError extends GoodIssueState {
  final String message;

  const GoodIssueError(this.message);
}
