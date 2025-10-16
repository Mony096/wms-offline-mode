import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class PhysicalCountRepository {
  Future<Either<Failure, Map<String, dynamic>>> post(
      Map<String, dynamic> entity);
  Future<Either<Failure, Map<String, dynamic>>> put(
      Map<String, dynamic> entity, dynamic docEntry);
}
