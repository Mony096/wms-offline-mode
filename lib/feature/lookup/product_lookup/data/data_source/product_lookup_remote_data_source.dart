import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class ProductLookUpRemoteDataSource {
  Future<Map<String, dynamic>> get(Map<String, dynamic> filter);
}

class ProductLookUpRemoteDataSourceImpl
    implements ProductLookUpRemoteDataSource {
  final DioClient dio;

  ProductLookUpRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> get(Map<String, dynamic> filter) async {
    try {
      final response = await dio.get(
          "/view.svc/ItemB1SLQuery?\$filter=ItemCode eq '${filter["itemCode"]}' and WhsCode eq '${filter["warehouseCode"]}'");
      return response.data as dynamic;
    } on Failure {
      rethrow;
    }
  }
}
