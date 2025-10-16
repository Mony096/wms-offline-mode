import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'put_away_state.dart';

class PutAwayCubit extends Cubit<PutAwayState> {
  PostPutAwayUseCase useCase;

  PutAwayCubit(this.useCase) : super(PutAwayInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingPutAway());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
