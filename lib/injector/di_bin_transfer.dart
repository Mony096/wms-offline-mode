import 'package:get_it/get_it.dart';

import '../feature/pick_and_pack/bin_transfer/data/data_source/bin_transfer_remote_data_source.dart';
import '../feature/pick_and_pack/bin_transfer/data/repository/bin_transfer_repository_impl.dart';
import '../feature/pick_and_pack/bin_transfer/domain/repository/bin_transfer_repository.dart';
import '../feature/pick_and_pack/bin_transfer/domain/usecase/post_usecase.dart';
import '../feature/pick_and_pack/bin_transfer/presentation/cubit/bin_transfer_cubit.dart';

class DIBinTransfer {
  final GetIt getIt;

  DIBinTransfer(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return BinTransferCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostBinTransferUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<BinTransferRepository>(() {
      return BinTransferRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<BinTransferRemoteDataSource>(() {
      return BinTransferRemoteDataSourceImpl(getIt());
    });
  }
}
