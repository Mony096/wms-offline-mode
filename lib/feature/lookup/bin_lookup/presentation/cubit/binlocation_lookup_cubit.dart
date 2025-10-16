import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/feature/lookup/bin_lookup/domain/usecase/get_usecase.dart';

part 'binlocation_lookup_state.dart';

class BinLookUpCubit extends Cubit<BinLookUpState> {
  GetBinLookUpUseCase useCase;

  BinLookUpCubit(this.useCase) : super(BinLookUpInitial());

  Future<Map<String, dynamic>> get(Map<String, dynamic> filter) async {
    emit(RequestingBinLookUp());
    final response = await useCase.call(filter);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
