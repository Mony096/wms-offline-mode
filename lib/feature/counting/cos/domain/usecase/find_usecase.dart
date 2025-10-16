import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/core/usecase/usecase.dart';
import 'package:wms_mobile/feature/counting/cos/domain/repository/cos_repository.dart';


class FindCosUseCase implements UseCase<dynamic, String> {
  final CosRepository repository;

  FindCosUseCase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(String query) async {
    return await repository.find(query);
  }
}
