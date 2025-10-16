import 'package:get_it/get_it.dart';

import '../feature/warehouse/data/data_source/warehouse_remote_data_source.dart';
import '../feature/warehouse/data/repository/warehouse_repository_impl.dart';
import '../feature/warehouse/domain/repository/warehouse_repository.dart';
import '../feature/warehouse/domain/usecase/get_usecase.dart';
import '../feature/warehouse/presentation/cubit/warehouse_cubit.dart';

class DIWarehouse {
  final GetIt getIt;

  DIWarehouse(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return WarehouseCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetWarehouseUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<WarehouseRepository>(() {
      return WarehouseRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<WarehouseRemoteDataSource>(() {
      return WarehouseRemoteDataSourceImpl(getIt());
    });
  }
}
