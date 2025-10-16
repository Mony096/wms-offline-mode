import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/purchase_good_receipt_repository.dart';
import '../data_source/purchase_good_receipt_remote_data_source.dart';

class PurchaseGoodReceiptRepositoryImpl
    implements PurchaseGoodReceiptRepository {
  final PurchaseGoodReceiptRemoteDataSource remote;

  PurchaseGoodReceiptRepositoryImpl(this.remote);

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
