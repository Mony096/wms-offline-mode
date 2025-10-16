import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/data/data_source/product_lookup_remote_data_source.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/data/repository/product_lookup_repository_impl.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/domain/repository/product_lookup_repository.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/lookup/product_lookup/presentation/cubit/product_lookup_cubit.dart';


class DIProductLookUp {
  final GetIt getIt;

  DIProductLookUp(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return ProductLookUpCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetProductLookUpUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<ProductLookUpRepository>(() {
      return ProductLookUpRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<ProductLookUpRemoteDataSource>(() {
      return ProductLookUpRemoteDataSourceImpl(getIt());
    });
  }
}
