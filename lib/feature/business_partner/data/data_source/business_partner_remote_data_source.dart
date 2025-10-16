import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class BusinessPartnerRemoteDataSource {
  Future<List<dynamic>> get(String query);
}

class BusinessPartnerRemoteDataSourceImpl
    implements BusinessPartnerRemoteDataSource {
  final DioClient dio;

  BusinessPartnerRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> get(String query) async {
    try {
      print('/BusinessPartners$query');
      final response = await dio.get('/BusinessPartners$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return response.data['value'] as List<dynamic>;
    } on Failure {
      rethrow;
    }
  }
}
