import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/feature/counting/cos/data/data_source/cos_remote_data_source.dart';
import 'package:wms_mobile/feature/counting/cos/domain/repository/cos_repository.dart';


class CosRepositoryImpl implements CosRepository {
  final CosRemoteDataSource remote;

  CosRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<dynamic>>> get(String query) async {
    try {
      final List<dynamic> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Failure, dynamic>> find(String query) async {
    try {
      final dynamic reponse = await remote.find(query);

      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
