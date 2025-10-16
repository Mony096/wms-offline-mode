import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class DeliveryRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final DioClient dio;

  DeliveryRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/DeliveryNotes', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
