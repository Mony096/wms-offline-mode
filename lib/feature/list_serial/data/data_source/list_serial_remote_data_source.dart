import '../model/serial_model.dart';
import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class ListSerialRemoteDataSource {
  Future<List<dynamic>> get(String query);
}

class ListSerialRemoteDataSourceImpl implements ListSerialRemoteDataSource {
  final DioClient dio;

  ListSerialRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> get(String query) async {
    try {
      final response =
          await dio.get('/view.svc/WMS_SERIAL_BATCHB1SLQuery$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return List.from(response.data['value']).map((e) => e).toList();
    } on Failure {
      rethrow;
    }
  }
}
