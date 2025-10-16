import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/unit_of_measurement/domain/entity/unit_of_measurement_entity.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/unit_of_measurement_repository.dart';
import '../data_source/unit_of_measurement_remote_data_source.dart';

class UnitOfMeasurementRepositoryImpl implements UnitOfMeasurementRepository {
  final UnitOfMeasurementRemoteDataSource remote;

  UnitOfMeasurementRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<UnitOfMeasurementEntity>>> get(
      String query) async {
    try {
      final List<UnitOfMeasurementEntity> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
