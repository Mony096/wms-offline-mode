import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entity/bin_entity.dart';
import '../../domain/usecase/get_usecase.dart';

part 'bin_state.dart';

class BinCubit extends Cubit<BinState> {
  GetBinUseCase useCase;

  BinCubit(this.useCase) : super(BinInitial());

  Future<List<BinEntity>> get(String query) async {
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

  Future<List<BinEntity>> next(String query) async {
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

  Future<void> set(List<BinEntity> data) async {
    emit(BinInitial());
    emit(BinData(data));
  }
}
