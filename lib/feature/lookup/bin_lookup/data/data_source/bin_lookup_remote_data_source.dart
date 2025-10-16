import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class BinLookUpRemoteDataSource {
  Future<Map<String, dynamic>> get(Map<String, dynamic> filter);
}

class BinLookUpRemoteDataSourceImpl implements BinLookUpRemoteDataSource {
  final DioClient dio;

  BinLookUpRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> get(Map<String, dynamic> filter) async {
    try {
      final response = await dio.get(
          "/view.svc/ItemB1SLQuery?\$filter=BinCode eq '${filter["binCode"]}' and WhsCode eq '${filter["warehouseCode"]}'");
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
