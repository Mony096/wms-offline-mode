import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../entity/unit_of_measurement_entity.dart';

abstract class UnitOfMeasurementRepository {
  Future<Either<Failure, List<UnitOfMeasurementEntity>>> get(String query);
}
