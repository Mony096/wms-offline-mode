import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/core/usecase/usecase.dart';
import 'package:wms_mobile/feature/counting/physical_count/domain/repository/physical_count_repository.dart';
import 'package:wms_mobile/feature/counting/physical_count/domain/usecase/param.dart';


class PutPhysicalCountUseCase
    implements UseCase<Map<String, dynamic>, PutPhysicalCountParams> {
  final PhysicalCountRepository repository;

  PutPhysicalCountUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      PutPhysicalCountParams params) async {
    return await repository.put(params.query, params.docEntry);
  }
}
