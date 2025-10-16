import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/counting/bin_count/data/data_source/bin_count_remote_data_source.dart';
import 'package:wms_mobile/feature/counting/bin_count/data/repository/bin_count_repository_impl.dart';
import 'package:wms_mobile/feature/counting/bin_count/domain/repository/bin_count_repository.dart';
import 'package:wms_mobile/feature/counting/bin_count/domain/usecase/post_usecase.dart';
import 'package:wms_mobile/feature/counting/bin_count/presentation/cubit/binlocation_count_cubit.dart';

class DIBinlocationCount {
  final GetIt getIt;

  DIBinlocationCount(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return BinlocationCountCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostBinlocationCountUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<BinCountRepository>(() {
      return BinlocationCountRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<BinCountRemoteDataSource>(() {
      return BinCountRemoteDataSourceImpl(getIt());
    });
  }
}
