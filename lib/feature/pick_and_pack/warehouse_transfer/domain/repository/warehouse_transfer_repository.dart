import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class WarehouseTransferRepository {
  WarehouseTransferRepository(Object object);

  Future<Either<Failure, Map<String, dynamic>>> post(
      Map<String, dynamic> entity);
}
