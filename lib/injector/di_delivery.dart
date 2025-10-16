import 'package:get_it/get_it.dart';

import '../feature/outbounce/delivery/data/data_source/delivery_remote_data_source.dart';
import '../feature/outbounce/delivery/data/repository/delivery_repository_impl.dart';
import '../feature/outbounce/delivery/domain/repository/delivery_repository.dart';
import '../feature/outbounce/delivery/domain/usecase/post_usecase.dart';
import '../feature/outbounce/delivery/presentation/cubit/delivery_cubit.dart';

class DIDelivery {
  final GetIt getIt;

  DIDelivery(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return DeliveryCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostDeliveryUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<DeliveryRepository>(() {
      return DeliveryRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<DeliveryRemoteDataSource>(() {
      return DeliveryRemoteDataSourceImpl(getIt());
    });
  }
}
