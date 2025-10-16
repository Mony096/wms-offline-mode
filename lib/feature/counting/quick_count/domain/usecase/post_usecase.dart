import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/quick_count_repository.dart';

class PostQuickCountUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final QuickCountRepository repository;

  PostQuickCountUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
