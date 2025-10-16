import 'package:dartz/dartz.dart';
import '../../domain/entity/list_batch_entity.dart';
import '../../domain/repository/list_batch_repository.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/list_batch_remote_data_source.dart';
import '../model/bin_model.dart';

class ListBatchRepositoryImpl implements ListBatchRepository {
  final ListBatchRemoteDataSource remote;

  ListBatchRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<dynamic>>> get(String query) async {
    try {
      final List<dynamic> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
