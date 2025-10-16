import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/post_usecase.dart';

part 'delivery_state.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  PostDeliveryUseCase useCase;

  DeliveryCubit(this.useCase) : super(DeliveryInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingDelivery());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
