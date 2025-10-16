import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class PurchaseOrderRepository {
  Future<Either<Failure, List<dynamic>>> get(String entity);
}
