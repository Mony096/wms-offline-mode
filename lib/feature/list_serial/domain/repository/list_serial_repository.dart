import 'package:dartz/dartz.dart';
import '../entity/list_serial_entity.dart';

import '../../../../../core/error/failure.dart';

abstract class ListSerialRepository {
  Future<Either<Failure, List<dynamic>>> get(String query);
}
