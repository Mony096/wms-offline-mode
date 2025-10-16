import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/counting/physical_count/data/data_source/physical_count_remote_data_source.dart';
import 'package:wms_mobile/feature/counting/physical_count/data/repository/physical_count_repository_impl.dart';
import 'package:wms_mobile/feature/counting/physical_count/domain/repository/physical_count_repository.dart';
import 'package:wms_mobile/feature/counting/physical_count/domain/usecase/put_usecase.dart';
import 'package:wms_mobile/feature/counting/physical_count/presentation/cubit/physical_count_cubit.dart';

class DIPhysicalCount {
  final GetIt getIt;

  DIPhysicalCount(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return PhysicalCountCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PutPhysicalCountUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<PhysicalCountRepository>(() {
      return PhysicalCountRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<PhysicalCountRemoteDataSource>(() {
      return PhysicalCountRemoteDataSourceImpl(getIt());
    });
  }
}
