import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/return_receipt_request_repository.dart';

class GetReturnReceiptRequestUseCase implements UseCase<List<dynamic>, String> {
  final ReturnReceiptRequestRepository repository;

  GetReturnReceiptRequestUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
