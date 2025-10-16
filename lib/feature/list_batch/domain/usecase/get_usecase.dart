import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/list_batch/domain/repository/list_batch_repository.dart';
import '../entity/list_batch_entity.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';

class GetListBatchUseCase implements UseCase<List<dynamic>, String> {
  final ListBatchRepository repository;

  GetListBatchUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
