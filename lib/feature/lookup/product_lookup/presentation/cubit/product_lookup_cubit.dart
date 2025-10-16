import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/get_usecase.dart';

part 'product_lookup_state.dart';

class ProductLookUpCubit extends Cubit<ProductLookUpState> {
  GetProductLookUpUseCase useCase;

  ProductLookUpCubit(this.useCase) : super(ProductLookUpInitial());

  Future<Map<String, dynamic>> get(Map<String, dynamic> filter) async {
    emit(RequestingProductLookUp());
    final response = await useCase.call(filter);
    return response.fold((error) {
      print(error.message);
      throw Exception(error.message);
    }, (success) async {
      return success;
    });
  }
}
