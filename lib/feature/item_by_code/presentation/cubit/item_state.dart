part of 'item_cubit.dart';

class ItemByCodeState extends Equatable {
  const ItemByCodeState();

  @override
  List<Object> get props => [];
}

class ItemInitial extends ItemByCodeState {}

class RequestingItem extends ItemByCodeState {}

class RequestingPaginationItem extends ItemByCodeState {}

class ItemData extends ItemByCodeState {
  final List<dynamic> entities;

  const ItemData(this.entities);
}

class ItemError extends ItemByCodeState {
  final String message;

  const ItemError(this.message);
}
