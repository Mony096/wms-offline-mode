import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/return_receipt_repository.dart';
import '../data_source/return_receipt_remote_data_source.dart';

class ReturnReceiptRepositoryImpl implements ReturnReceiptRepository {
  final ReturnReceiptRemoteDataSource remote;

  ReturnReceiptRepositoryImpl(this.remote);

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
