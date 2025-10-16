import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/feature/list_serial/domain/entity/list_serial_entity.dart';
import 'package:wms_mobile/feature/list_serial/domain/usecase/get_usecase.dart';

part 'serialNumber_list_state.dart';

class SerialListCubit extends Cubit<SerialListState> {
  GetListSerialUseCase useCase;

  SerialListCubit(this.useCase) : super(BinInitial());

  Future<List<dynamic>> get(String query) async {
    emit(RequestingBin());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(BinError(error.message));
      return [];
    }, (success) async {
      emit(BinData(success));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationBin());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(BinError(error.message));
      return [];
    }, (success) async {
      emit(BinData([]));
      return success;
    });
  }

  Future<void> set(List<dynamic> data) async {
    emit(BinInitial());
    emit(BinData(data));
  }
}
