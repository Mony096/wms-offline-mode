import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/purchase_return_request_repository.dart';
import '../data_source/purchase_return_request_remote_data_source.dart';

class PurchaseReturnRequestRepositoryImpl
    implements PurchaseReturnRequestRepository {
  final PurchaseReturnRequestRemoteDataSource remote;

  PurchaseReturnRequestRepositoryImpl(this.remote);

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
