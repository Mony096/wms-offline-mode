import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/sale_order_repository.dart';

class GetSaleOrderUseCase implements UseCase<List<dynamic>, String> {
  final SaleOrderRepository repository;

  GetSaleOrderUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
