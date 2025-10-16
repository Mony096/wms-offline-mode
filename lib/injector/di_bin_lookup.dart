import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/data/data_source/bin_lookup_remote_data_source.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/domain/repository/bin_lookup_repository.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/data/repository/bin_lookup_repository_impl.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/presentation/cubit/binlocation_lookup_cubit.dart';


class DIBinLookUp {
  final GetIt getIt;

  DIBinLookUp(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return BinLookUpCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetBinLookUpUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<BinLookUpRepository>(() {
      return BinLookUpRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<BinLookUpRemoteDataSource>(() {
      return BinLookUpRemoteDataSourceImpl(getIt());
    });
  }
}
