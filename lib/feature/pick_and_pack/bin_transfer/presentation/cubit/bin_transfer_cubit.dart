import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'bin_transfer_state.dart';

class BinTransferCubit extends Cubit<BinTransferState> {
  PostBinTransferUseCase useCase;

  BinTransferCubit(this.useCase) : super(BinTransferInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingBinTransfer());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
