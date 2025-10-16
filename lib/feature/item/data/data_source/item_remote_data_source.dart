import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:wms_mobile/utilies/database/database.dart';

import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class ItemRemoteDataSource {
  Future<List<dynamic>> get(String query);
  Future<dynamic> find(String query);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final DioClient dio;
  final DatabaseHelper db;

  ItemRemoteDataSourceImpl(this.dio, this.db);

  @override
  Future<List<dynamic>> get(String query) async {
    try {
      final response = await dio.get('/Items$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      final items = response.data['value'] as List<dynamic>;

      return items;
    } on Failure {
      rethrow;
    }
  }

  @override
  Future find(String query) async {
    try {
      final response = await dio.get('/Items$query');
      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      final uomGroup = await dio.get(
        '/UnitOfMeasurementGroups(${response.data['UoMGroupEntry']})',
      );

      return {
        ...response.data,
        "BaseUoM": uomGroup.data['BaseUoM'],
        "UoMGroupDefinitionCollection":
            uomGroup.data['UoMGroupDefinitionCollection'],
      };
    } on Failure {
      rethrow;
    }
  }
}
