import 'package:dartz/dartz.dart';
import '../../domain/entity/list_serial_entity.dart';
import '../../domain/repository/list_serial_repository.dart';

import '../../../../../core/error/failure.dart';
import '../data_source/list_serial_remote_data_source.dart';
import '../model/serial_model.dart';

class ListSerialRepositoryImpl implements ListSerialRepository {
  final ListSerialRemoteDataSource remote;

  ListSerialRepositoryImpl(this.remote);

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
