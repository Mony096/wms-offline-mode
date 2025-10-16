import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/physical_count_remote_data_source.dart';
import '../../domain/repository/physical_count_repository.dart';

class PhysicalCountRepositoryImpl implements PhysicalCountRepository {
  final PhysicalCountRemoteDataSource remote;

  PhysicalCountRepositoryImpl(this.remote);

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
  @override
  Future<Either<Failure, Map<String, dynamic>>> put(
      Map<String, dynamic> payload,docEntry) async {
    try {
      final Map<String, dynamic> reponse = await remote.put(payload,docEntry);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
