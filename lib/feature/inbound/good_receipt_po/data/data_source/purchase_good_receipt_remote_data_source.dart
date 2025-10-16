import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class PurchaseGoodReceiptRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class PurchaseGoodReceiptRemoteDataSourceImpl
    implements PurchaseGoodReceiptRemoteDataSource {
  final DioClient dio;

  PurchaseGoodReceiptRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/PurchaseDeliveryNotes', data: payload);
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
