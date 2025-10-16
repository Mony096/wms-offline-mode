import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/put_away_repository.dart';

class PostPutAwayUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final PutAwayRepository repository;

  PostPutAwayUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
