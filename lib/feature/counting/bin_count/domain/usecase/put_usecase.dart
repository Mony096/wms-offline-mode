import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/core/usecase/usecase.dart';
import 'package:wms_mobile/feature/counting/bin_count/domain/repository/bin_count_repository.dart';
import 'package:wms_mobile/feature/counting/bin_count/domain/usecase/param.dart';


class PutBinCountUseCase
    implements UseCase<Map<String, dynamic>, PutBinCountParams> {
  final BinCountRepository repository;

  PutBinCountUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      PutBinCountParams params) async {
    return await repository.put(params.query, params.docEntry);
  }
}
