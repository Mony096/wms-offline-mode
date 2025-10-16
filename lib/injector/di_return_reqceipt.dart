import 'package:get_it/get_it.dart';

import '../feature/inbound/return_receipt/data/data_source/return_receipt_remote_data_source.dart';
import '../feature/inbound/return_receipt/data/repository/return_receipt_repository_impl.dart';
import '../feature/inbound/return_receipt/domain/repository/return_receipt_repository.dart';
import '../feature/inbound/return_receipt/domain/usecase/post_usecase.dart';
import '../feature/inbound/return_receipt/presentation/cubit/return_receipt_cubit.dart';

class DIReturnReceipt {
  final GetIt getIt;

  DIReturnReceipt(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return ReturnReceiptCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostReturnReceiptUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<ReturnReceiptRepository>(() {
      return ReturnReceiptRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<ReturnReceiptRemoteDataSource>(() {
      return ReturnReceiptRemoteDataSourceImpl(getIt());
    });
  }
}
