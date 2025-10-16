import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/warehouse/data/model/warehouse_model.dart';
import 'package:wms_mobile/feature/warehouse/domain/entity/warehouse_entity.dart';
import '../../domain/repository/warehouse_repository.dart';
import '/feature/warehouse/data/data_source/warehouse_remote_data_source.dart';

import '../../../../../core/error/failure.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final WarehouseRemoteDataSource remote;

  WarehouseRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<WarehouseEntity>>> get(String query) async {
    try {
      final List<Warehouse> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
