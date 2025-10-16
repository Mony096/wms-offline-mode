import 'dart:convert';
import 'dart:developer';

import 'package:wms_mobile/feature/middleware/data/model/login_model.dart';

import '../../../../core/error/failure.dart';
import '../../../../utilies/dio_client.dart';

abstract class LoginRemoteDataSource {
  Future<String> sign(LoginModel entity);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final DioClient dio;

  LoginRemoteDataSourceImpl(this.dio);

  @override
  Future<String> sign(LoginModel entity) async {
    try {
      final response = await dio.post('/Login', data: entity.toJson());

      if (response.statusCode != 200) {
        throw ServerFailure(message: response.data['msg']);
      }

      return response.data['SessionId'];
    } on Failure {
      rethrow;
    }
  }
}
