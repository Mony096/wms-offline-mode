import 'package:wms_mobile/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class ReturnReceiptRequestRemoteDataSource {
  Future<List<dynamic>> get(String query);
}

class ReturnReceiptRequestRemoteDataSourceImpl
    implements ReturnReceiptRequestRemoteDataSource {
  final DioClient dio;

  ReturnReceiptRequestRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> get(String query) async {
    try {
      final response = await dio.get('/ReturnRequest$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return response.data['value'] as List<dynamic>;
    } on Failure {
      rethrow;
    }
  }
}
