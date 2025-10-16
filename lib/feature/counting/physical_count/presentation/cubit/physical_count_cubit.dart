import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_mobile/feature/counting/physical_count/domain/usecase/param.dart';
import 'package:wms_mobile/feature/counting/physical_count/domain/usecase/put_usecase.dart';

part 'physical_count_state.dart';

class PhysicalCountCubit extends Cubit<PhysicalCountState> {
  final PutPhysicalCountUseCase useCase;

  PhysicalCountCubit(this.useCase) : super(PhysicalCountInitial());

  Future<Map<String, dynamic>> put(
      dynamic query, int docEntry) async {
    emit(RequestingPhysicalCount());
    final params = PutPhysicalCountParams(query: query, docEntry: docEntry);
    final response = await useCase.call(params);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) {
      return success;
    });
  }
}
