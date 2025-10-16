import 'package:dartz/dartz.dart';
import 'package:wms_mobile/core/error/failure.dart';


abstract class CosRepository {
  Future<Either<Failure, List<dynamic>>> get(String query);
  Future<Either<Failure, dynamic>> find(String query);
}
