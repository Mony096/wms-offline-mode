import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/counting/cos/data/data_source/cos_remote_data_source.dart';
import 'package:wms_mobile/feature/counting/cos/data/repository/cos_repository_impl.dart';
import 'package:wms_mobile/feature/counting/cos/domain/repository/cos_repository.dart';
import 'package:wms_mobile/feature/counting/cos/domain/usecase/find_usecase.dart';
import 'package:wms_mobile/feature/counting/cos/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/counting/cos/presentation/cubit/cos_cubit.dart';



class DICos {
  final GetIt getIt;

  DICos(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return CosCubit(getIt(), getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetCosUseCase(getIt());
    });

    getIt.registerLazySingleton(() {
      return FindCosUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<CosRepository>(() {
      return CosRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<CosRemoteDataSource>(() {
      return CosRemoteDataSourceImpl(getIt(), getIt());
    });
  }
}
