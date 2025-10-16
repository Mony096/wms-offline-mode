import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/core/usecase/usecase.dart';
import 'package:wms_mobile/feature/counting/cos/domain/repository/cos_repository.dart';


class GetCosUseCase implements UseCase<List<dynamic>, String> {
  final CosRepository repository;

  GetCosUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
