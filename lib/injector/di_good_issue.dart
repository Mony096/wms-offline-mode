import 'package:get_it/get_it.dart';

import '../feature/outbounce/good_issue/data/data_source/good_issue_remote_data_source.dart';
import '../feature/outbounce/good_issue/data/repository/good_issue_repository_impl.dart';
import '../feature/outbounce/good_issue/domain/repository/good_issue_repository.dart';
import '../feature/outbounce/good_issue/domain/usecase/post_usecase.dart';
import '../feature/outbounce/good_issue/presentation/cubit/good_issue_cubit.dart';

class DIGoodIssue {
  final GetIt getIt;

  DIGoodIssue(this.getIt) {
    // ********* Bloc **********
    getIt.registerFactory(() {
      return GoodIssueCubit(getIt());
    });

    //********* Use Cases **********
    getIt.registerLazySingleton(() {
      return PostGoodIssueUseCase(getIt());
    });

    // ********* Repositories **********
    getIt.registerLazySingleton<GoodIssueRepository>(() {
      return GoodIssueRepositoryImpl(getIt());
    });

    // ********* Data Sources **********
    getIt.registerLazySingleton<GoodIssueRemoteDataSource>(() {
      return GoodIssueRemoteDataSourceImpl(getIt());
    });
  }
}
