import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/feature/inbound/good_receipt_po/domain/usecase/post_usecase.dart';

part 'purchase_good_receipt_state.dart';

class PurchaseGoodReceiptCubit extends Cubit<PurchaseGoodReceiptState> {
  PostPurchaseGoodReceiptUseCase useCase;

  PurchaseGoodReceiptCubit(this.useCase) : super(PurchaseGoodReceiptInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingPurchaseGoodReceipt());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
