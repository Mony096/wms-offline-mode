import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/component/item/data/data_source/item_remote_data_source.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/component/item/data/repository/item_repository_impl.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/component/item/domain/repository/item_repository.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/component/item/domain/usecase/find_usecase.dart';
import 'package:wms_mobile/feature/inbound/return_receipt/component/item/domain/usecase/get_usecase.dart';

import '../feature/inbound/return_receipt/component/item/presentation/cubit/item_cubit.dart';


class DIItems {
  final GetIt getIt;

  DIItems(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return ItemCubits(getIt(), getIt());
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
