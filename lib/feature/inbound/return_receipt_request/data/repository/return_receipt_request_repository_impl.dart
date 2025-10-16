import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/return_receipt_request_repository.dart';
import '../data_source/return_receipt_request_remote_data_source.dart';

class ReturnReceiptRequestRepositoryImpl
    implements ReturnReceiptRequestRepository {
  final ReturnReceiptRequestRemoteDataSource remote;

  ReturnReceiptRequestRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<dynamic>>> get(String query) async {
    try {
      final List<dynamic> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
