import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/good_receipt_type/data/data_source/grt_remote_data_source.dart';
import 'package:wms_mobile/feature/good_receipt_type/data/repository/grt_repository_impl.dart';
import 'package:wms_mobile/feature/good_receipt_type/domain/repository/grt_repository.dart';
import 'package:wms_mobile/feature/good_receipt_type/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/good_receipt_type/presentation/cubit/grt_cubit.dart';

import '../feature/bin_location/data/data_source/bin_remote_data_source.dart';
import '../feature/bin_location/data/repository/bin_repository_impl.dart';
import '../feature/bin_location/domain/repository/bin_repository.dart';
import '../feature/bin_location/domain/usecase/get_usecase.dart';
import '../feature/bin_location/presentation/cubit/bin_cubit.dart';

class DIGrt {
  final GetIt getIt;

  DIGrt(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return GrtCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetGrtUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<GrtRepository>(() {
      return GrtRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<GrtRemoteDataSource>(() {
      return GrtRemoteDataSourceImpl(getIt());
    });
  }
}
