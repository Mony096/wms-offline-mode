import 'package:get_it/get_it.dart';

import '../feature/inbound/good_receipt/data/data_source/good_receipt_remote_data_source.dart';
import '../feature/inbound/good_receipt/data/repository/good_receipt_repository_impl.dart';
import '../feature/inbound/good_receipt/domain/repository/good_receipt_repository.dart';
import '../feature/inbound/good_receipt/domain/usecase/post_usecase.dart';
import '../feature/inbound/good_receipt/presentation/cubit/good_receipt_cubit.dart';

class DIGoodReceipt {
  final GetIt getIt;

  DIGoodReceipt(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return GoodReceiptCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostGoodReceiptUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<GoodReceiptRepository>(() {
      return GoodReceiptRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<GoodReceiptRemoteDataSource>(() {
      return GoodReceiptRemoteDataSourceImpl(getIt());
    });
  }
}
