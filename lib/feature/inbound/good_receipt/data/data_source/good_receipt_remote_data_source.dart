import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class GoodReceiptRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class GoodReceiptRemoteDataSourceImpl implements GoodReceiptRemoteDataSource {
  final DioClient dio;

  GoodReceiptRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/InventoryGenEntries', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
