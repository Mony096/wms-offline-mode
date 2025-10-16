import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '/feature/warehouse/domain/entity/warehouse_entity.dart';
import '/feature/warehouse/domain/usecase/get_usecase.dart';

part 'warehouse_state.dart';

class WarehouseCubit extends Cubit<WarehouseState> {
  GetWarehouseUseCase useCase;

  WarehouseCubit(this.useCase) : super(WarehouseInitial());

  Future<List<WarehouseEntity>> get(String query) async {
    emit(RequestingWarehouse());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(WarehouseError(error.message));
      return [];
    }, (success) async {
      emit(WarehouseData(success));
      return success;
    });
  }

  Future<List<WarehouseEntity>> next(String query) async {
    emit(RequestingPaginationWarehouse());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(WarehouseError(error.message));
      return [];
    }, (success) async {
      emit(WarehouseData([]));
      return success;
    });
  }

  Future<void> set(List<WarehouseEntity> data) async {
    emit(WarehouseInitial());
    emit(WarehouseData(data));
  }
}
