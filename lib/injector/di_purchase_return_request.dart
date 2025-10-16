import 'package:get_it/get_it.dart';

import '../feature/outbounce/purchase_return_request/data/data_source/purchase_return_request_remote_data_source.dart';
import '../feature/outbounce/purchase_return_request/data/repository/purchase_return_request_repository_impl.dart';
import '../feature/outbounce/purchase_return_request/domain/repository/purchase_return_request_repository.dart';
import '../feature/outbounce/purchase_return_request/domain/usecase/get_usecase.dart';
import '../feature/outbounce/purchase_return_request/presentation/cubit/purchase_return_request_cubit.dart';

class DIPurchaseReturnRequest {
  final GetIt getIt;

  DIPurchaseReturnRequest(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return PurchaseReturnRequestCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetPurchaseReturnRequestUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<PurchaseReturnRequestRepository>(() {
      return PurchaseReturnRequestRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<PurchaseReturnRequestRemoteDataSource>(() {
      return PurchaseReturnRequestRemoteDataSourceImpl(getIt());
    });
  }
}
