import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';

abstract class BusinessPartnerRepository {
  Future<Either<Failure, List<dynamic>>> get(String query);
}
