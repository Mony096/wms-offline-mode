import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/domain/repository/bin_lookup_repository.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/bin_lookup_remote_data_source.dart';

class BinLookUpRepositoryImpl implements BinLookUpRepository {
  final BinLookUpRemoteDataSource remote;

  BinLookUpRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> get(
      Map<String, dynamic> filter) async {
    try {
      final Map<String, dynamic> reponse = await remote.get(filter);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
