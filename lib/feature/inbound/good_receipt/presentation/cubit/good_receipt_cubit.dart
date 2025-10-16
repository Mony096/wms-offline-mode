import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'good_receipt_state.dart';

class GoodReceiptCubit extends Cubit<GoodReceiptState> {
  PostGoodReceiptUseCase useCase;

  GoodReceiptCubit(this.useCase) : super(GoodReceiptInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingGoodReceipt());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
