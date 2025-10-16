import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/feature/counting/bin_count/domain/usecase/post_usecase.dart';

part 'binlocation_count_state.dart';

class BinlocationCountCubit extends Cubit<BinlocationCountState> {
  PostBinlocationCountUseCase useCase;
  BinlocationCountCubit(this.useCase) : super(BinlocationCountInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingBinlocationCount());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
