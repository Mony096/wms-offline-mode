import 'package:get_it/get_it.dart';
import 'package:wms_mobile/feature/good_isuse_select/data/data_source/grt_remote_data_source.dart';
import 'package:wms_mobile/feature/good_isuse_select/data/repository/grt_repository_impl.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/repository/grt_repository.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/usecase/get_usecase.dart';
import 'package:wms_mobile/feature/good_isuse_select/presentation/cubit/grt_cubit.dart';

import '../feature/bin_location/data/data_source/bin_remote_data_source.dart';
import '../feature/bin_location/data/repository/bin_repository_impl.dart';
import '../feature/bin_location/domain/repository/bin_repository.dart';
import '../feature/bin_location/domain/usecase/get_usecase.dart';
import '../feature/bin_location/presentation/cubit/bin_cubit.dart';

class DIGoodIssueSelect {
  final GetIt getIt;

  DIGoodIssueSelect(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return GoodIssueSelectCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return GetGoodIssueSelectUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<GoodIssueSelectRepository>(() {
      return GoodIssueSelectRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<GoodIssueSelectRemoteDataSource>(() {
      return GoodIssueSelectRemoteDataSourceImpl(getIt());
    });
  }
}
