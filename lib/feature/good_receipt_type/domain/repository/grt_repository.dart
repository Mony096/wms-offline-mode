import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/good_receipt_type/domain/entity/grt_entity.dart';
import '/feature/bin_location/domain/entity/bin_entity.dart';

import '../../../../../core/error/failure.dart';

abstract class GrtRepository {
  Future<Either<Failure, List<GrtEntity>>> get(String query);
}
