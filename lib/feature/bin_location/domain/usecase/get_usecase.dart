import 'package:dartz/dartz.dart';
import '/feature/bin_location/domain/repository/bin_repository.dart';
import '../entity/bin_entity.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';

class GetBinUseCase implements UseCase<List<BinEntity>, String> {
  final BinRepository repository;

  GetBinUseCase(this.repository);

  @override
  Future<Either<Failure, List<BinEntity>>> call(String query) async {
    return await repository.get(query);
  }
}
