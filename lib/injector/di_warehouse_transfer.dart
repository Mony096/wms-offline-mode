import 'package:get_it/get_it.dart';

import '../feature/pick_and_pack/warehouse_transfer/data/data_source/warehouse_transfer_remote_data_source.dart';
import '../feature/pick_and_pack/warehouse_transfer/data/repository/warehouse_transfer_repository_impl.dart';
import '../feature/pick_and_pack/warehouse_transfer/domain/repository/warehouse_transfer_repository.dart';
import '../feature/pick_and_pack/warehouse_transfer/domain/usecase/post_usecase.dart';
import '../feature/pick_and_pack/warehouse_transfer/presentation/cubit/warehouse_transfer_cubit.dart';

class DiWarehouseTransfer {
  final GetIt getIt;

  DiWarehouseTransfer(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return WarehouseTransferCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostWarehouseTransferUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<WarehouseTransferRepository>(() {
      return WarehouseTransferRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<WarehouseTransferRemoteDataSource>(() {
      return WarehouseTransferRemoteDataSourceImpl(getIt());
    });
  }
}
