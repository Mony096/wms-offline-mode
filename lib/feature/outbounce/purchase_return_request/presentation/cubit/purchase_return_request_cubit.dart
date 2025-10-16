import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/get_usecase.dart';

part 'purchase_return_request_state.dart';

class PurchaseReturnRequestCubit extends Cubit<PurchaseReturnRequestState> {
  GetPurchaseReturnRequestUseCase useCase;

  PurchaseReturnRequestCubit(this.useCase)
      : super(PurchaseReturnRequestInitial());

  Future<List<dynamic>> get(String query) async {
    emit(RequestingPurchaseReturnRequest());

    final response = await useCase.call(query);
    return response.fold((error) {
      emit(PurchaseReturnRequestError(error.message));
      return [];
    }, (success) async {
      emit(PurchaseReturnRequestData(success));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationPurchaseReturnRequest());
    print('requesting next po.....');

    final response = await useCase.call(query);
    return response.fold((error) {
      emit(PurchaseReturnRequestError(error.message));
      return [];
    }, (success) async {
      emit(PurchaseReturnRequestData([]));
      return success;
    });
  }

  Future<void> remove(int docEntry) async {
    List<dynamic> data = [];

    if (state is PurchaseReturnRequestData) {
      data = [...(state as PurchaseReturnRequestData).entities];
    }
    data.removeWhere((row) => row['DocEntry'] == docEntry);
    emit(PurchaseReturnRequestInitial());
    emit(PurchaseReturnRequestData(data));
  }
}
