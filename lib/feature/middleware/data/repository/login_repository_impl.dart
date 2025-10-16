import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/middleware/data/model/login_model.dart';
import 'package:wms_mobile/feature/middleware/domain/entity/login_entity.dart';
import 'package:wms_mobile/feature/middleware/domain/repository/login_repository.dart';

import '../../../../core/error/failure.dart';
import '../data_source/login_remote_data_source.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remote;

  LoginRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, String>> post(LoginEntity entity) async {
    try {
      final String reponse = await remote.sign(LoginModel.mapFromEntity(entity));

      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
