import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/core/usecase/usecase.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/entity/grt_entity.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/repository/grt_repository.dart';

class GetGoodIssueSelectUseCase implements UseCase<List<GoodIssueSelectEntity>, String> {
  final GoodIssueSelectRepository repository;

  GetGoodIssueSelectUseCase(this.repository);

  @override
  Future<Either<Failure, List<GoodIssueSelectEntity>>> call(String query) async {
    return await repository.get(query);
  }
}
