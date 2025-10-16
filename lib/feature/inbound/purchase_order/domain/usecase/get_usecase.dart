import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/purchase_order_repository.dart';

class GetPurchaseOrderUseCase implements UseCase<List<dynamic>, String> {
  final PurchaseOrderRepository repository;

  GetPurchaseOrderUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
