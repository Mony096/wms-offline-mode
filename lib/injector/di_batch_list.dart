import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/list_batch/data/data_source/list_batch_remote_data_source.dart';
import 'package:wms_mobile/feature/list_batch/data/repository/list_batch_repository_impl.dart';
import 'package:wms_mobile/feature/list_batch/domain/repository/list_batch_repository.dart';
import 'package:wms_mobile/feature/list_batch/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/list_batch/presentation/cubit/batch_list_cubit.dart';


class DIBatchListSelect {
  final GetIt getIt;

  DIBatchListSelect(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return BatchListCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetListBatchUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<ListBatchRepository>(() {
      return ListBatchRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<ListBatchRemoteDataSource>(() {
      return ListBatchRemoteDataSourceImpl(getIt());
    });
  }
}
