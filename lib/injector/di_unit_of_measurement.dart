import 'package:get_it/get_it.dart';

import '../feature/unit_of_measurement/data/data_source/unit_of_measurement_remote_data_source.dart';
import '../feature/unit_of_measurement/data/repository/unit_of_measurement_repository_impl.dart';
import '../feature/unit_of_measurement/domain/repository/unit_of_measurement_repository.dart';
import '../feature/unit_of_measurement/domain/usecase/get_usecase.dart';
import '../feature/unit_of_measurement/presentation/cubit/uom_cubit.dart';

class DIUnitOfMeasurement {
  final GetIt getIt;

  DIUnitOfMeasurement(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return UnitOfMeasurementCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetUnitOfMeasurementUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<UnitOfMeasurementRepository>(() {
      return UnitOfMeasurementRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<UnitOfMeasurementRemoteDataSource>(() {
      return UnitOfMeasurementRemoteDataSourceImpl(getIt());
    });
  }
}
