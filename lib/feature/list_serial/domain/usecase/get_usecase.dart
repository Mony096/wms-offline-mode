import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/list_serial/domain/repository/list_serial_repository.dart';
import '../entity/list_serial_entity.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';

class GetListSerialUseCase implements UseCase<List<dynamic>, String> {
  final ListSerialRepository repository;

  GetListSerialUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
