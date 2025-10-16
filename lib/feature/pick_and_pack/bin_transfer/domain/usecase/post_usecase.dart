import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/bin_transfer_repository.dart';

class PostBinTransferUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final BinTransferRepository repository;

  PostBinTransferUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> query) async {
    return await repository.post(query);
  }
}
