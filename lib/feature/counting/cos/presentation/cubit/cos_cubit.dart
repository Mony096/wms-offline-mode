import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/core/error/failure.dart';
import 'package:wms_mobile/feature/counting/cos/domain/usecase/find_usecase.dart';
import 'package:wms_mobile/feature/counting/cos/domain/usecase/get_usecase.dart';


part 'cos_state.dart';

class CosCubit extends Cubit<CosState> {
  GetCosUseCase useCase;
  FindCosUseCase findUseCase;

  CosCubit(this.useCase, this.findUseCase) : super(CosInitial());

  Future<List<dynamic>> get(String query, {bool cache = true}) async {
    List<dynamic> data = [];
    if (state is CosData) data = (state as CosData).entities;

    emit(RequestingCos());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(CosError(error.message));
      return [];
    }, (success) async {
      emit(CosData(cache ? success : data));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationCos());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(CosError(error.message));
      return [];
    }, (success) async {
      emit(CosData([]));
      return success;
    });
  }

  Future<void> set(List<dynamic> data) async {
    emit(CosInitial());
    emit(CosData(data));
  }

  Future<dynamic> find(String query, {bool cache = true}) async {
    final response = await findUseCase.call(query);

    return response.fold((error) {
      throw ServerFailure(message: error.message);
    }, (success) async {
      return success;
    });
  }
}
