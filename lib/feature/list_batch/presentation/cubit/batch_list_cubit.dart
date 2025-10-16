import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entity/list_batch_entity.dart';
import '../../domain/usecase/get_usecase.dart';

part 'batch_list_state.dart';

class BatchListCubit extends Cubit<BatchListState> {
  GetListBatchUseCase useCase;

  BatchListCubit(this.useCase) : super(BinInitial());

  Future<List<dynamic>> get(String query) async {
    emit(RequestingBin());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(BinError(error.message));
      return [];
    }, (success) async {
      emit(BinData(success));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationBin());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(BinError(error.message));
      return [];
    }, (success) async {
      emit(BinData([]));
      return success;
    });
  }

  Future<void> set(List<dynamic> data) async {
    emit(BinInitial());
    emit(BinData(data));
  }
}
