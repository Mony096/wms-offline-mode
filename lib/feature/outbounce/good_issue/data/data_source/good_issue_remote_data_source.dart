import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class GoodIssueRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class GoodIssueRemoteDataSourceImpl implements GoodIssueRemoteDataSource {
  final DioClient dio;

  GoodIssueRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/InventoryGenExits', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
