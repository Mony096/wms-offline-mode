import 'package:get_it/get_it.dart';

import '../feature/outbounce/sale_order/data/data_source/sale_order_remote_data_source.dart';
import '../feature/outbounce/sale_order/data/repository/sale_order_repository_impl.dart';
import '../feature/outbounce/sale_order/domain/repository/sale_order_repository.dart';
import '../feature/outbounce/sale_order/domain/usecase/get_usecase.dart';
import '../feature/outbounce/sale_order/presentation/cubit/sale_order_cubit.dart';

class DISaleOrder {
  final GetIt getIt;

  DISaleOrder(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return SaleOrderCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetSaleOrderUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<SaleOrderRepository>(() {
      return SaleOrderRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<SaleOrderRemoteDataSource>(() {
      return SaleOrderRemoteDataSourceImpl(getIt());
    });
  }
}
