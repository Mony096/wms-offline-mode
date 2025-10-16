part of 'item_cubit.dart';

class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object> get props => [];
}

class ItemInitial extends ItemState {}

class RequestingItem extends ItemState {}

class RequestingPaginationItem extends ItemState {}

class ItemData extends ItemState {
  final List<dynamic> entities;

  const ItemData(this.entities);
}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);
}
