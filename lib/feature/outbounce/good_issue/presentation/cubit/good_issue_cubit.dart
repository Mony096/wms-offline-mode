import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/post_usecase.dart';

part 'good_issue_state.dart';

class GoodIssueCubit extends Cubit<GoodIssueState> {
  PostGoodIssueUseCase useCase;

  GoodIssueCubit(this.useCase) : super(GoodIssueInitial());

  Future<Map<String, dynamic>> post(Map<String, dynamic> query) async {
    emit(RequestingGoodIssue());
    final response = await useCase.call(query);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
