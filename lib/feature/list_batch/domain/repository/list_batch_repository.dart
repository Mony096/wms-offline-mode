import 'package:dartz/dartz.dart';
import '../entity/list_batch_entity.dart';

import '../../../../../core/error/failure.dart';

abstract class ListBatchRepository {
  Future<Either<Failure, List<dynamic>>> get(String query);
}
