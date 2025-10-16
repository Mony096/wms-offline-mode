import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/sale_order_repository.dart';
import '../data_source/sale_order_remote_data_source.dart';

class SaleOrderRepositoryImpl implements SaleOrderRepository {
  final SaleOrderRemoteDataSource remote;

  SaleOrderRepositoryImpl(this.remote);

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
