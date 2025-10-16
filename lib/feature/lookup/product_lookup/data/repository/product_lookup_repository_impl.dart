import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/domain/repository/product_lookup_repository.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/product_lookup_remote_data_source.dart';

class ProductLookUpRepositoryImpl implements ProductLookUpRepository {
  final ProductLookUpRemoteDataSource remote;

  ProductLookUpRepositoryImpl(this.remote);

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
