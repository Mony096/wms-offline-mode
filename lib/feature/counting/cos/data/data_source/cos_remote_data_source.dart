
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/utilies/database/database.dart';

import '/utilies/dio_client.dart';

abstract class CosRemoteDataSource {
  Future<List<dynamic>> get(String query);
  Future<dynamic> find(String query);
}

class CosRemoteDataSourceImpl implements CosRemoteDataSource {
  final DioClient dio;
  final DatabaseHelper db;

  CosRemoteDataSourceImpl(this.dio, this.db);

  @override
  Future<List<dynamic>> get(String query) async {
    try {
      final response = await dio.get('/InventoryCountings$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      final Coss = response.data['value'] as List<dynamic>;

      return Coss;
    } on Failure {
      rethrow;
    }
  }

  @override
  Future find(String query) async {
    try {
      final response = await dio.get('/InventoryCountings$query');
      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return response.data;
    } on Failure {
      rethrow;
    }
  }
}
