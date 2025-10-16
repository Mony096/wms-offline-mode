import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class ReturnReceiptRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class ReturnReceiptRemoteDataSourceImpl
    implements ReturnReceiptRemoteDataSource {
  final DioClient dio;

  ReturnReceiptRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/Returns', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
