import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/get_usecase.dart';

part 'return_receipt_request_state.dart';

class ReturnReceiptRequestCubit extends Cubit<ReturnReceiptRequestState> {
  GetReturnReceiptRequestUseCase useCase;

  ReturnReceiptRequestCubit(this.useCase)
      : super(ReturnReceiptRequestInitial());
  Future<List<dynamic>> get(String query) async {
    emit(RequestingReturnReceiptRequest());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(ReturnReceiptRequestError(error.message));
      return [];
    }, (success) async {
      emit(ReturnReceiptRequestData(success));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationReturnReceiptRequest());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(ReturnReceiptRequestError(error.message));
      return [];
    }, (success) async {
      emit(ReturnReceiptRequestData([]));
      return success;
    });
  }

  Future<void> set(List<dynamic> data) async {
    emit(ReturnReceiptRequestInitial());
    emit(ReturnReceiptRequestData(data));
  }
}
