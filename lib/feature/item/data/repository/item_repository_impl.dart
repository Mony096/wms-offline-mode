import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/repository/item_repository.dart';
import '../data_source/item_remote_data_source.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remote;

  ItemRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<dynamic>>> get(String query) async {
    try {
      final List<dynamic> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Failure, dynamic>> find(String query) async {
    try {
      final dynamic reponse = await remote.find(query);

      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
