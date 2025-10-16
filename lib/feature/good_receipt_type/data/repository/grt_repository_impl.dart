import 'package:dartz/dartz.dart';
import '../../domain/entity/grt_entity.dart';
import '../../domain/repository/grt_repository.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/grt_remote_data_source.dart';
import '../model/grt_model.dart';

class GrtRepositoryImpl implements GrtRepository {
  final GrtRemoteDataSource remote;

  GrtRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<GrtEntity>>> get(String query) async {
    try {
      final List<Grt> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
