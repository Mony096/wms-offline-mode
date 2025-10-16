import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'return_receipt_state.dart';

class ReturnReceiptCubit extends Cubit<ReturnReceiptState> {
  PostReturnReceiptUseCase useCase;

  ReturnReceiptCubit(this.useCase) : super(ReturnReceiptInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingReturnReceipt());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
