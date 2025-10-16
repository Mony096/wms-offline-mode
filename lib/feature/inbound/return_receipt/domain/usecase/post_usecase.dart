import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/return_receipt_repository.dart';

class PostReturnReceiptUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final ReturnReceiptRepository repository;

  PostReturnReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
