import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class PurchaseReturnRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class PurchaseReturnRemoteDataSourceImpl
    implements PurchaseReturnRemoteDataSource {
  final DioClient dio;

  PurchaseReturnRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/PurchaseReturns', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
