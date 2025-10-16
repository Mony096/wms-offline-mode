import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/bin_transfer_repository.dart';
import '../data_source/bin_transfer_remote_data_source.dart';

class BinTransferRepositoryImpl implements BinTransferRepository {
  final BinTransferRemoteDataSource remote;

  BinTransferRepositoryImpl(this.remote);

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
