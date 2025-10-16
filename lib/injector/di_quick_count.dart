import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/counting/quick_count/data/data_source/quick_count_remote_data_source.dart';
import 'package:wms_mobile/feature/counting/quick_count/data/repository/quick_count_repository_impl.dart';
import 'package:wms_mobile/feature/counting/quick_count/domain/repository/quick_count_repository.dart';
import 'package:wms_mobile/feature/counting/quick_count/domain/usecase/post_usecase.dart';
import 'package:wms_mobile/feature/counting/quick_count/presentation/cubit/quick_count_cubit.dart';

class DIQuickCount {
  final GetIt getIt;

  DIQuickCount(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return QuickCountCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostQuickCountUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<QuickCountRepository>(() {
      return QuickCountRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<QuickCountRemoteDataSource>(() {
      return QuickCountRemoteDataSourceImpl(getIt());
    });
  }
}
