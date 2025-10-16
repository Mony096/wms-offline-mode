import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/good_issue_repository.dart';

class PostGoodIssueUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final GoodIssueRepository repository;

  PostGoodIssueUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
