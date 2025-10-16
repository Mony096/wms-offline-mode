import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/item/domain/repository/item_repository.dart';
import '../../../../../../../core/error/failure.dart';
import '../../../../../../../core/usecase/usecase.dart';

class FindItemUseCase implements UseCase<dynamic, String> {
  final ItemRepository repository;

  FindItemUseCase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(String query) async {
    return await repository.find(query);
  }
}
