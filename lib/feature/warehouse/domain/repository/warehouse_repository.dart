import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../entity/warehouse_entity.dart';

abstract class WarehouseRepository {
  Future<Either<Failure, List<WarehouseEntity>>> get(String query);
}
