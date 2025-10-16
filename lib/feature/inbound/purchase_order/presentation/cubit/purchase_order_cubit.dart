import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/get_usecase.dart';

part 'purchase_order_state.dart';

class PurchaseOrderCubit extends Cubit<PurchaseOrderState> {
  GetPurchaseOrderUseCase useCase;

  PurchaseOrderCubit(this.useCase) : super(PurchaseOrderInitial());

  Future<List<dynamic>> get(String query) async {
    emit(RequestingPurchaseOrder());
    print('requesting po.....');

    final response = await useCase.call(query);
    return response.fold((error) {
      emit(PurchaseOrderError(error.message));
      return [];
    }, (success) async {
      emit(PurchaseOrderData(success));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationPurchaseOrder());
    print('requesting next po.....');

    final response = await useCase.call(query);
    return response.fold((error) {
      emit(PurchaseOrderError(error.message));
      return [];
    }, (success) async {
      emit(PurchaseOrderData([]));
      return success;
    });
  }

  Future<void> remove(int docEntry) async {
    List<dynamic> data = [];

    if (state is PurchaseOrderData) {
      data = [...(state as PurchaseOrderData).entities];
    }
    data.removeWhere((row) => row['DocEntry'] == docEntry);
    emit(PurchaseOrderInitial());
    emit(PurchaseOrderData(data));
  }
}
