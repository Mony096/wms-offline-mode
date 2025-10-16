import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'quick_count_state.dart';

class QuickCountCubit extends Cubit<QuickCountState> {
  PostQuickCountUseCase useCase;

  QuickCountCubit(this.useCase) : super(QuickCountInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingQuickCount());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
