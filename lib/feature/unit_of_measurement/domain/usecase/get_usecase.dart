import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/unit_of_measurement/domain/entity/unit_of_measurement_entity.dart';
import '../repository/unit_of_measurement_repository.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';

class GetUnitOfMeasurementUseCase
    implements UseCase<List<UnitOfMeasurementEntity>, String> {
  final UnitOfMeasurementRepository repository;

  GetUnitOfMeasurementUseCase(this.repository);

  @override
  Future<Either<Failure, List<UnitOfMeasurementEntity>>> call(
      String query) async {
    return await repository.get(query);
  }
}
