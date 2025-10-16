import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecase/get_usecase.dart';

part 'business_partner_state.dart';

class BusinessPartnerCubit extends Cubit<BusinessPartnerState> {
  GetBusinessPartnerUseCase useCase;

  BusinessPartnerCubit(this.useCase) : super(BusinessPartnerInitial());

  Future<List<dynamic>> get(String query) async {
    emit(RequestingBusinessPartner());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(BusinessPartnerError(error.message));
      return [];
    }, (success) async {
      emit(BusinessPartnerData(success));
      return success;
    });
  }

  Future<List<dynamic>> next(String query) async {
    emit(RequestingPaginationBusinessPartner());
    final response = await useCase.call(query);
    return response.fold((error) {
      emit(BusinessPartnerError(error.message));
      return [];
    }, (success) async {
      emit(BusinessPartnerData([]));
      return success;
    });
  }

  Future<void> set(List<dynamic> data) async {
    emit(BusinessPartnerInitial());
    emit(BusinessPartnerData(data));
  }
}
