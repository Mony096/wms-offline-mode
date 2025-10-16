// import 'package:dartz/dartz.dart';

// import '../../../../../core/error/failure.dart';
// import '../data_source/bin_count_remote_data_source.dart';
// import '../../domain/repository/Bin_count_repository.dart';

// class BinCountRepositoryImpl implements BinCountRepository {
//   final BinCountRemoteDataSource remote;

//   BinCountRepositoryImpl(this.remote);

//   @override
//   Future<Either<Failure, Map<String, dynamic>>> post(
//       Map<String, dynamic> payload) async {
//     try {
//       final Map<String, dynamic> reponse = await remote.post(payload);
//       return Right(reponse);
//     } on Failure catch (error) {
//       return Left(error);
//     }
//   }
// }
import 'package:dartz/dartz.dart';
import 'package:wms_mobile/feature/counting/bin_count/data/data_source/bin_count_remote_data_source.dart';
import 'package:wms_mobile/feature/counting/bin_count/domain/repository/bin_count_repository.dart';

import '../../../../../core/error/failure.dart';

class BinlocationCountRepositoryImpl implements BinCountRepository {
  final BinCountRemoteDataSource remote;

  BinlocationCountRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> post(
      Map<String, dynamic> payload) async {
    try {
      final Map<String, dynamic> reponse = await remote.post(payload);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> put(
      Map<String, dynamic> payload, docEntry) async {
    try {
      final Map<String, dynamic> reponse = await remote.put(payload, docEntry);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
