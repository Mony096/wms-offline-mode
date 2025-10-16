import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/physical_count_repository.dart';

class PostPhysicalCountUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final PhysicalCountRepository repository;

  PostPhysicalCountUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
