import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/delivery_repository.dart';

class PostDeliveryUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final DeliveryRepository repository;

  PostDeliveryUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
