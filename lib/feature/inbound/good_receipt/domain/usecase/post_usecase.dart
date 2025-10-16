import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/good_receipt_repository.dart';

class PostGoodReceiptUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final GoodReceiptRepository repository;

  PostGoodReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
