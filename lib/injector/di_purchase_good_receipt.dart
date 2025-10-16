import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/domain/usecase/post_usecase.dart';

import '../feature/inbound/good_receipt_po/data/data_source/purchase_good_receipt_remote_data_source.dart';
import '../feature/inbound/good_receipt_po/data/repository/purchase_good_receipt_repository_impl.dart';
import '../feature/inbound/good_receipt_po/domain/repository/purchase_good_receipt_repository.dart';
import '../feature/inbound/good_receipt_po/presentation/cubit/purchase_good_receipt_cubit.dart';

class DIPurchaseGoodReceipt {
  final GetIt getIt;

  DIPurchaseGoodReceipt(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return PurchaseGoodReceiptCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostPurchaseGoodReceiptUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<PurchaseGoodReceiptRepository>(() {
      return PurchaseGoodReceiptRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<PurchaseGoodReceiptRemoteDataSource>(() {
      return PurchaseGoodReceiptRemoteDataSourceImpl(getIt());
    });
  }
}
