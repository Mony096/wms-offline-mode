import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entity/unit_of_measurement_entity.dart';
import '../../domain/usecase/get_usecase.dart';

part 'uom_state.dart';

class UnitOfMeasurementCubit extends Cubit<UnitOfMeasurementState> {
  GetUnitOfMeasurementUseCase useCase;

  UnitOfMeasurementCubit(this.useCase) : super(UnitOfMeasurementInitial());

  Future<List<UnitOfMeasurementEntity>> get(String query) async {
    emit(RequestingUnitOfMeasurement());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(UnitOfMeasurementError(error.message));
      return [];
    }, (success) async {
      emit(UnitOfMeasurementData(success));
      return success;
    });
  }

  Future<List<UnitOfMeasurementEntity>> next(String query) async {
    emit(RequestingPaginationUnitOfMeasurement());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(UnitOfMeasurementError(error.message));
      return [];
    }, (success) async {
      emit(UnitOfMeasurementData([]));
      return success;
    });
  }

  Future<void> set(List<UnitOfMeasurementEntity> data) async {
    emit(UnitOfMeasurementInitial());
    emit(UnitOfMeasurementData(data));
  }
}
