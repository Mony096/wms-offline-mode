import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/entity/grt_entity.dart';


abstract class GoodIssueSelectRepository {
  Future<Either<Failure, List<GoodIssueSelectEntity>>> get(String query);
}
