import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/purchase_good_receipt_repository.dart';

class PostPurchaseGoodReceiptUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final PurchaseGoodReceiptRepository repository;

  PostPurchaseGoodReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
