import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/warehouse_transfer_repository.dart';

class PostWarehouseTransferUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final WarehouseTransferRepository repository;

  PostWarehouseTransferUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
