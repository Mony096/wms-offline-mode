import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/bin_count_repository.dart';

class PostBinlocationCountUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final BinCountRepository repository;

  PostBinlocationCountUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
