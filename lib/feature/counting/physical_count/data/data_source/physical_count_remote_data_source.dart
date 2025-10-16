import 'dart:convert';

import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class PhysicalCountRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> put(Map<String, dynamic> payload, docEntry);
}

class PhysicalCountRemoteDataSourceImpl
    implements PhysicalCountRemoteDataSource {
  final DioClient dio;

  PhysicalCountRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/InventoryCountings', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> put(
      Map<String, dynamic> payload, docEntry) async {
    try {
      final response =
          await dio.put('/InventoryCountings($docEntry)', data: payload);

      // Ensure response.data is not null and not an empty string
      if (response.data == null ||
          (response.data is String && response.data.isEmpty)) {
        return {
          'status': 'success',
          'message': 'Operation completed successfully',
          'data': {}
        };
      }
      // Decode if response.data is a String
      if (response.data is String) {
        try {
          return jsonDecode(response.data) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Error decoding JSON: $e');
        }
      } else if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response type');
      }
    } on Failure {
      rethrow;
    }
  }
}
