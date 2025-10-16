import 'package:get_it/get_it.dart';

import '../feature/inbound/return_receipt_request/data/data_source/return_receipt_request_remote_data_source.dart';
import '../feature/inbound/return_receipt_request/data/repository/return_receipt_request_repository_impl.dart';
import '../feature/inbound/return_receipt_request/domain/repository/return_receipt_request_repository.dart';
import '../feature/inbound/return_receipt_request/domain/usecase/get_usecase.dart';
import '../feature/inbound/return_receipt_request/presentation/cubit/return_receipt_request_cubit.dart';

class DIReturnReceiptRequest {
  final GetIt getIt;

  DIReturnReceiptRequest(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return ReturnReceiptRequestCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetReturnReceiptRequestUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<ReturnReceiptRequestRepository>(() {
      return ReturnReceiptRequestRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<ReturnReceiptRequestRemoteDataSource>(() {
      return ReturnReceiptRequestRemoteDataSourceImpl(getIt());
    });
  }
}
