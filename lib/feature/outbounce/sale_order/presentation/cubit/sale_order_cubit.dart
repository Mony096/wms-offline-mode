import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/get_usecase.dart';

part 'sale_order_state.dart';

class SaleOrderCubit extends Cubit<SaleOrderState> {
  GetSaleOrderUseCase useCase;

  SaleOrderCubit(this.useCase) : super(SaleOrderInitial());

  Future<List<dynamic>> get(String query) async {
    emit(RequestingSaleOrder());

    final response = await useCase.call(query);
    return response.fold((error) {
      emit(SaleOrderError(error.message));
      return [];
    }, (success) async {
      emit(SaleOrderData(success));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationSaleOrder());
    print('requesting next po.....');

    final response = await useCase.call(query);
    return response.fold((error) {
      emit(SaleOrderError(error.message));
      return [];
    }, (success) async {
      emit(SaleOrderData([]));
      return success;
    });
  }

  Future<void> remove(int docEntry) async {
    List<dynamic> data = [];

    if (state is SaleOrderData) {
      data = [...(state as SaleOrderData).entities];
    }
    data.removeWhere((row) => row['DocEntry'] == docEntry);
    emit(SaleOrderInitial());
    emit(SaleOrderData(data));
  }
}
