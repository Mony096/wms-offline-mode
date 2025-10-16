import 'package:get_it/get_it.dart';

import '../feature/business_partner/data/data_source/business_partner_remote_data_source.dart';
import '../feature/business_partner/data/repository/business_partner_repository_impl.dart';
import '../feature/business_partner/domain/repository/business_partner_repository.dart';
import '../feature/business_partner/domain/usecase/get_usecase.dart';
import '../feature/business_partner/presentation/cubit/business_partner_cubit.dart';

class DIBusinessPartner {
  final GetIt getIt;

  DIBusinessPartner(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return BusinessPartnerCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetBusinessPartnerUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<BusinessPartnerRepository>(() {
      return BusinessPartnerRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<BusinessPartnerRemoteDataSource>(() {
      return BusinessPartnerRemoteDataSourceImpl(getIt());
    });
  }
}
