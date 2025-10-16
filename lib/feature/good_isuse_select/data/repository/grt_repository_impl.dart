import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/feature/good_isuse_select/data/data_source/grt_remote_data_source.dart';
import 'package:wms_mobile/feature/good_isuse_select/data/model/grt_model.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/entity/grt_entity.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/repository/grt_repository.dart';

class GoodIssueSelectRepositoryImpl implements GoodIssueSelectRepository {
  final GoodIssueSelectRemoteDataSource remote;

  GoodIssueSelectRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<GoodIssueSelectEntity>>> get(String query) async {
    try {
      final List<GoodIssueSelect> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
