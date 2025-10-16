import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/good_receipt_type/domain/repository/grt_repository.dart';
import '../entity/grt_entity.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';

class GetGrtUseCase implements UseCase<List<GrtEntity>, String> {
  final GrtRepository repository;

  GetGrtUseCase(this.repository);

  @override
  Future<Either<Failure, List<GrtEntity>>> call(String query) async {
    return await repository.get(query);
  }
}
