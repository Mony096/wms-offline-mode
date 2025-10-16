import 'package:wms_mobile/feature/unit_of_measurement/data/model/unit_of_measurement_model.dart';

import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class UnitOfMeasurementRemoteDataSource {
  Future<List<UnitOfMeasurementModel>> get(String query);
}

class UnitOfMeasurementRemoteDataSourceImpl
    implements UnitOfMeasurementRemoteDataSource {
  final DioClient dio;

  UnitOfMeasurementRemoteDataSourceImpl(this.dio);

  @override
  Future<List<UnitOfMeasurementModel>> get(String query) async {
    try {
      final response = await dio.get('/UnitOfMeasurements$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return List.from(response.data['value'])
          .map((e) => UnitOfMeasurementModel.fromJson(e))
          .toList();
    } on Failure {
      rethrow;
    }
  }
}
