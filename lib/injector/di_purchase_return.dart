import 'package:get_it/get_it.dart';

import '../feature/outbounce/purchase_return/data/data_source/purchase_return_remote_data_source.dart';
import '../feature/outbounce/purchase_return/data/repository/purchase_return_repository_impl.dart';
import '../feature/outbounce/purchase_return/domain/repository/purchase_return_repository.dart';
import '../feature/outbounce/purchase_return/domain/usecase/post_usecase.dart';
import '../feature/outbounce/purchase_return/presentation/cubit/purchase_return_cubit.dart';

class DIPurchaseReturn {
  final GetIt getIt;

  DIPurchaseReturn(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return PurchaseReturnCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostPurchaseReturnUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<PurchaseReturnRepository>(() {
      return PurchaseReturnRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<PurchaseReturnRemoteDataSource>(() {
      return PurchaseReturnRemoteDataSourceImpl(getIt());
    });
  }
}
