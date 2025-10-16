import '/feature/warehouse/data/model/warehouse_model.dart';
import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class WarehouseRemoteDataSource {
  Future<List<Warehouse>> get(String query);
}

class WarehouseRemoteDataSourceImpl implements WarehouseRemoteDataSource {
  final DioClient dio;

  WarehouseRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Warehouse>> get(String query) async {
    try {
      final response = await dio.get('/Warehouses$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return List.from(response.data['value'])
          .map((e) => Warehouse.fromJson(e))
          .toList();
    } on Failure {
      rethrow;
    }
  }
}
