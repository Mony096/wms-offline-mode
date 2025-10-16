import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class ItemRepository {
  Future<Either<Failure, List<dynamic>>> get(String query);
  Future<Either<Failure, dynamic>> find(String query);
}
