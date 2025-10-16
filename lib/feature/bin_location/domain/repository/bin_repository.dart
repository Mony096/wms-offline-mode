import 'package:dartz/dartz.dart';
import '/feature/bin_location/domain/entity/bin_entity.dart';

import '../../../../../core/error/failure.dart';

abstract class BinRepository {
  Future<Either<Failure, List<BinEntity>>> get(String query);
}
