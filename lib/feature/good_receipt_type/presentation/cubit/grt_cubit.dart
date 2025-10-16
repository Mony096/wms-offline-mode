import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entity/grt_entity.dart';
import '../../domain/usecase/get_usecase.dart';

part 'grt_state.dart';

class GrtCubit extends Cubit<GrtState> {
  GetGrtUseCase useCase;

  GrtCubit(this.useCase) : super(GrtInitial());

  Future<List<GrtEntity>> get(String query) async {
    emit(RequestingGrt());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(GrtError(error.message));
      return [];
    }, (success) async {
      emit(GrtData(success));
      return success;
    });
  }

  Future<List<GrtEntity>> next(String query) async {
    emit(RequestingPaginationGrt());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(GrtError(error.message));
      return [];
    }, (success) async {
      emit(GrtData([]));
      return success;
    });
  }

  Future<void> set(List<GrtEntity> data) async {
    emit(GrtInitial());
    emit(GrtData(data));
  }
}
