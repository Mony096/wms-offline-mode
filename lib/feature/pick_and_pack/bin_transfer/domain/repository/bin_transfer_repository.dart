import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class BinTransferRepository {
  BinTransferRepository(Object object);

  Future<Either<Failure, Map<String, dynamic>>> post(
      Map<String, dynamic> entity);
}
