import 'package:dartz/dartz.dart';
import '/feature/warehouse/domain/repository/warehouse_repository.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../entity/warehouse_entity.dart';

class GetWarehouseUseCase implements UseCase<List<WarehouseEntity>, String> {
  final WarehouseRepository repository;

  GetWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, List<WarehouseEntity>>> call(String query) async {
    return await repository.get(query);
  }
}
