



import 'package:dartz/dartz.dart';
import '/feature/middleware/domain/entity/login_entity.dart';

import '../../../../core/error/failure.dart';

abstract class LoginRepository {
  Future<Either<Failure, String>> post(LoginEntity entity);
}
