import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class ProductLookUpRepository {
  Future<Either<Failure, Map<String, dynamic>>> get(
      Map<String, dynamic> filter);
}
