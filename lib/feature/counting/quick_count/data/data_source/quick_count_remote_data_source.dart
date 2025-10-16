import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class QuickCountRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class QuickCountRemoteDataSourceImpl implements QuickCountRemoteDataSource {
  final DioClient dio;

  QuickCountRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/InventoryPostings', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
