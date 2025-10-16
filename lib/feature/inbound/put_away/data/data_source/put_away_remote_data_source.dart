import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class PutAwayRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class PutAwayRemoteDataSourceImpl implements PutAwayRemoteDataSource {
  final DioClient dio;

  PutAwayRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/StockTransfers', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
