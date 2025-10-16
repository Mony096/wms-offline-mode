import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class SaleOrderRepository {
  Future<Either<Failure, List<dynamic>>> get(String entity);
}
