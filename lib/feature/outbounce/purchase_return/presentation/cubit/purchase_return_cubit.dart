import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'purchase_return_state.dart';

class PurchaseReturnCubit extends Cubit<PurchaseReturnState> {
  PostPurchaseReturnUseCase useCase;

  PurchaseReturnCubit(this.useCase) : super(PurchaseReturnInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingPurchaseReturn());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
