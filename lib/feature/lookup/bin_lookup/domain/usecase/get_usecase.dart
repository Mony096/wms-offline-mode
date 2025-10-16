import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/bin_lookup_repository.dart';

class GetBinLookUpUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final BinLookUpRepository repository;

  GetBinLookUpUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> filter) async {
    return await repository.get(filter);
  }
}
