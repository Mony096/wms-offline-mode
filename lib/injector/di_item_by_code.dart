import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/item_by_code/data/data_source/item_remote_data_source.dart';
import 'package:wms_mobile/feature/item_by_code/data/repository/item_repository_impl.dart';
import 'package:wms_mobile/feature/item_by_code/domain/repository/item_repository.dart';
import 'package:wms_mobile/feature/item_by_code/domain/usecase/find_usecase.dart';
import 'package:wms_mobile/feature/item_by_code/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/item_by_code/presentation/cubit/item_cubit.dart';

class DIItemByCode {
  final GetIt getIt;

  DIItemByCode(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return ItemByCodeCubit(getIt(), getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetItemUseCase(getIt());
    });

    getIt.registerLazySingleton(() {
      return FindItemUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<ItemRepository>(() {
      return ItemRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<ItemRemoteDataSource>(() {
      return ItemRemoteDataSourceImpl(getIt(), getIt());
    });
  }
}
