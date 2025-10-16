import 'package:wms_mobile/feature/good_isuse_select/data/model/grt_model.dart';

import '/utilies/dio_client.dart';
import '../../../../../core/error/failure.dart';

abstract class GoodIssueSelectRemoteDataSource {
  Future<List<GoodIssueSelect>> get(String query);
}

class GoodIssueSelectRemoteDataSourceImpl implements GoodIssueSelectRemoteDataSource {
  final DioClient dio;

  GoodIssueSelectRemoteDataSourceImpl(this.dio);

  @override
  Future<List<GoodIssueSelect>> get(String query) async {
    try {
      final response = await dio.get('/LK_OIGE$query');

      if (response.statusCode != 200) {
        throw ServerFailure(message: 'error');
      }

      return List.from(response.data['value'])
          .map((e) => GoodIssueSelect.fromJson(e))
          .toList();
    } on Failure {
      rethrow;
    }
  }
}
