import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../../good_receipt/data/data_source/good_receipt_remote_data_source.dart';
import '../../../good_receipt/domain/repository/good_receipt_repository.dart';

class GoodReceiptRepositoryImpl implements GoodReceiptRepository {
  final GoodReceiptRemoteDataSource remote;

  GoodReceiptRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> post(
      Map<String, dynamic> payload) async {
    try {
      final Map<String, dynamic> reponse = await remote.post(payload);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
