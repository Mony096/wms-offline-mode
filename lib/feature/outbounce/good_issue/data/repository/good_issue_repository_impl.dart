import 'package:dartz/dartz.dart';
import '/feature/outbounce/good_issue/domain/repository/good_issue_repository.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/good_issue_remote_data_source.dart';

class GoodIssueRepositoryImpl implements GoodIssueRepository {
  final GoodIssueRemoteDataSource remote;

  GoodIssueRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> post(
      Map<String, dynamic> payload) async {
    try {
      final Map<String, dynamic> reponse = await remote.post(payload);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
