import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class PurchaseReturnRequestRemoteDataSource {
  Future<List<dynamic>> get(String query);
}

class PurchaseReturnRequestRemoteDataSourceImpl
    implements PurchaseReturnRequestRemoteDataSource {
  final DioClient dio;

  PurchaseReturnRequestRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> get(String query) async {
    try {
      final response = await dio.get('/GoodsReturnRequest$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return response.data['value'] as List<dynamic>;
    } on Failure {
      rethrow;
    }
  }
}
