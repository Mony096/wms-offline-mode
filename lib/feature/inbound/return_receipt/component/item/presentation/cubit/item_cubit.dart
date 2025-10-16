import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/core/error/failure.dart';

import '../../domain/usecase/find_usecase.dart';
import '../../domain/usecase/get_usecase.dart';

part 'item_state.dart';

class ItemCubits extends Cubit<ItemStates> {
  GetItemUseCase useCase;
  FindItemUseCase findUseCase;

  ItemCubits(this.useCase, this.findUseCase) : super(ItemInitial());

  Future<List<dynamic>> get(String query, {bool cache = true}) async {
    List<dynamic> data = [];
    if (state is ItemData) data = (state as ItemData).entities;

    emit(RequestingItem());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(ItemError(error.message));
      return [];
    }, (success) async {
      emit(ItemData(cache ? success : data));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationItem());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(ItemError(error.message));
      return [];
    }, (success) async {
      emit(ItemData([]));
      return success;
    });
  }

  Future<void> set(List<dynamic> data) async {
    emit(ItemInitial());
    emit(ItemData(data));
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
