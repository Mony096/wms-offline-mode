import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/quick_count_remote_data_source.dart';
import '../../domain/repository/quick_count_repository.dart';

class QuickCountRepositoryImpl implements QuickCountRepository {
  final QuickCountRemoteDataSource remote;

  QuickCountRepositoryImpl(this.remote);

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
