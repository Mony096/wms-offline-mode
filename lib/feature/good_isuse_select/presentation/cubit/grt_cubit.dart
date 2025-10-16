import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/entity/grt_entity.dart';
import 'package:wms_mobile/feature/good_isuse_select/domain/usecase/get_usecase.dart';


part 'grt_state.dart';

class GoodIssueSelectCubit extends Cubit<GoodIssueSelectState> {
  GetGoodIssueSelectUseCase useCase;

  GoodIssueSelectCubit(this.useCase) : super(GoodIssueSelectInitial());

  Future<List<GoodIssueSelectEntity>> get(String query) async {
    emit(RequestingGoodIssueSelect());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(GoodIssueSelectError(error.message));
      return [];
    }, (success) async {
      emit(GoodIssueSelectData(success));
      return success;
    });
  }

  Future<List<GoodIssueSelectEntity>> next(String query) async {
    emit(RequestingPaginationGoodIssueSelect());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(GoodIssueSelectError(error.message));
      return [];
    }, (success) async {
      emit(GoodIssueSelectData([]));
      return success;
    });
  }

  Future<void> set(List<GoodIssueSelectEntity> data) async {
    emit(GoodIssueSelectInitial());
    emit(GoodIssueSelectData(data));
  }
}
