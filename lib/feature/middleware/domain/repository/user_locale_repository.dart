import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class UserLocaleRepository {
  Future<Either<Failure, String>> create(dynamic entity);
  Future<Either<Failure, String>> get(dynamic entity);
  Future<Either<Failure, String>> find(dynamic entity);
  Future<Either<Failure, String>> delete(dynamic entity);
}
