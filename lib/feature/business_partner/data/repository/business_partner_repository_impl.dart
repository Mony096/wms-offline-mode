import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/repository/business_partner_repository.dart';
import '../data_source/business_partner_remote_data_source.dart';

class BusinessPartnerRepositoryImpl implements BusinessPartnerRepository {
  final BusinessPartnerRemoteDataSource remote;

  BusinessPartnerRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<dynamic>>> get(String query) async {
    try {
      final List<dynamic> reponse = await remote.get(query);
      return Right(reponse);
    } on Failure catch (error) {
      return Left(error);
    }
  }
}
