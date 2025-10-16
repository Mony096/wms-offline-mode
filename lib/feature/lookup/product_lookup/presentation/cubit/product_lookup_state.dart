part of 'product_lookup_cubit.dart';

class ProductLookUpState extends Equatable {
  const ProductLookUpState();

  @override
  List<Object> get props => [];
}

class ProductLookUpInitial extends ProductLookUpState {}

class RequestingProductLookUp extends ProductLookUpState {}

class RequestingPaginationProductLookUp extends ProductLookUpState {}

class ProductLookUpData extends ProductLookUpState {
  final Map<String, dynamic> entities;

  const ProductLookUpData(this.entities);
}

class ProductLookUpError extends ProductLookUpState {
  final String message;

  const ProductLookUpError(this.message);
}
