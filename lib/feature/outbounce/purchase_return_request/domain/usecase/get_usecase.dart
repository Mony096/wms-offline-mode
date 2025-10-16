import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/purchase_return_request_repository.dart';

class GetPurchaseReturnRequestUseCase
    implements UseCase<List<dynamic>, String> {
  final PurchaseReturnRequestRepository repository;

  GetPurchaseReturnRequestUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
