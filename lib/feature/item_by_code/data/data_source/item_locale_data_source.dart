import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:wms_mobile/utilies/database/database.dart';

import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class ItemLocaleDataSource {
  Future<List<dynamic>> get(String query);
  Future<dynamic> create(dynamic query, {bool many});
  Future<dynamic> find(String query);
}

class ItemLocaleDataSourceImpl implements ItemLocaleDataSource {
  final DatabaseHelper db;

  ItemLocaleDataSourceImpl(this.db);

  @override
  Future<List<dynamic>> get(String query) async {
    return [];
    // try {
    //   final response = await dio.get('/Items$query');

    //   if (response.statusCode != 200) {
    //     throw ServerFailure(message: 'error');
    //   }

    //   return response.data['value'] as List<dynamic>;
    // } on Failure {
    //   rethrow;
    // }
  }

  @override
  Future find(String query) async {
    try {
      final database = await db.database;
      // final item = database.query('items', where: [])

      // final response = await dio.get('/Items$query');
      // if (response.statusCode != 200) {
      //   throw ServerFailure(message: 'error');
      // }

      // final uomGroup = await dio.get(
      //   '/UnitOfMeasurementGroups(${response.data['UoMGroupEntry']})',
      // );

      // return {
      //   ...response.data,
      //   "BaseUoM": uomGroup.data['BaseUoM'],
      //   "UoMGroupDefinitionCollection":
      //       uomGroup.data['UoMGroupDefinitionCollection'],
      // };
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<dynamic> create(dynamic data, {bool many = false}) async {
    final items = data is List<dynamic> ? [...data] : [data];

    final database = await db.database;
    var batch = database.batch();

    for (var item in items) {
      batch.insert(
          'items',
          {
            "ItemCode": item['ItemCode'],
            "ItemName": item['ItemName'],
            "UoMGroupEntry": item['UoMGroupEntry'],
            "InventoryUOM": item['InventoryUOM'],
            "InventoryUoMEntry": item['InventoryUoMEntry'],
            "PurchaseItem": item['PurchaseItem'],
            "SalesItem": item['SalesItem'],
            "InventoryItem": item['InventoryItem'],
            "UoMGroupDefinitionCollection":
                jsonEncode(item['UoMGroupDefinitionCollection'] ?? []),
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
