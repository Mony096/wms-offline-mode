import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class WarehouseTransferRemoteDataSource {
  Future<Map<String, dynamic>> post(Map<String, dynamic> payload);
}

class WarehouseTransferRemoteDataSourceImpl
    implements WarehouseTransferRemoteDataSource {
  final DioClient dio;

  WarehouseTransferRemoteDataSourceImpl(this.dio);

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
