import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/item/domain/repository/item_repository.dart';
import '../../../../../../../core/error/failure.dart';
import '../../../../../../../core/usecase/usecase.dart';

class GetItemUseCase implements UseCase<List<dynamic>, String> {
  final ItemRepository repository;

  GetItemUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
