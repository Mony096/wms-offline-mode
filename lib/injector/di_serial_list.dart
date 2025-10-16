import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/list_serial/data/data_source/list_serial_remote_data_source.dart';
import 'package:wms_mobile/feature/list_serial/data/repository/list_serial_repository_impl.dart';
import 'package:wms_mobile/feature/list_serial/domain/repository/list_serial_repository.dart';
import 'package:wms_mobile/feature/list_serial/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/list_serial/presentation/cubit/serialNumber_list_cubit.dart';

class DISerialListSelect {
  final GetIt getIt;

  DISerialListSelect(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return SerialListCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetListSerialUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<ListSerialRepository>(() {
      return ListSerialRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<ListSerialRemoteDataSource>(() {
      return ListSerialRemoteDataSourceImpl(getIt());
    });
  }
}
