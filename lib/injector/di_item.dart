import 'package:get_it/get_it.dart';

import '../feature/item/data/data_source/item_remote_data_source.dart';
import '../feature/item/data/repository/item_repository_impl.dart';
import '../feature/item/domain/repository/item_repository.dart';
import '../feature/item/domain/usecase/find_usecase.dart';
import '../feature/item/domain/usecase/get_usecase.dart';
import '../feature/item/presentation/cubit/item_cubit.dart';

class DIItem {
  final GetIt getIt;

  DIItem(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return ItemCubit(getIt(), getIt());
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
