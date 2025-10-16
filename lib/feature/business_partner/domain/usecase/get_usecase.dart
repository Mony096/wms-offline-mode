import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../repository/business_partner_repository.dart';

class GetBusinessPartnerUseCase implements UseCase<List<dynamic>, String> {
  final BusinessPartnerRepository repository;

  GetBusinessPartnerUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String query) async {
    return await repository.get(query);
  }
}
