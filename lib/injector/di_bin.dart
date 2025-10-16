import 'package:get_it/get_it.dart';

import '../feature/bin_location/data/data_source/bin_remote_data_source.dart';
import '../feature/bin_location/data/repository/bin_repository_impl.dart';
import '../feature/bin_location/domain/repository/bin_repository.dart';
import '../feature/bin_location/domain/usecase/get_usecase.dart';
import '../feature/bin_location/presentation/cubit/bin_cubit.dart';

class DIBin {
  final GetIt getIt;

  DIBin(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return BinCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetBinUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<BinRepository>(() {
      return BinRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<BinRemoteDataSource>(() {
      return BinRemoteDataSourceImpl(getIt());
    });
  }
}
