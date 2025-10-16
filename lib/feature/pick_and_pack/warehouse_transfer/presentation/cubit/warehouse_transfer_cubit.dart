import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'warehouse_transfer_state.dart';

class WarehouseTransferCubit extends Cubit<WarehouseTransferState> {
  PostWarehouseTransferUseCase useCase;

  WarehouseTransferCubit(this.useCase) : super(WarehouseTransferInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingWarehouseTransfer());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
