import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/purchase_return_repository.dart';

class PostPurchaseReturnUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final PurchaseReturnRepository repository;

  PostPurchaseReturnUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
