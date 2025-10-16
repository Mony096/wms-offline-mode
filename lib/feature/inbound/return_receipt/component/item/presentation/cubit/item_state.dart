part of 'item_cubit.dart';

class ItemStates extends Equatable {
  const ItemStates();

  @override
  List<Object> get props => [];
}

class ItemInitial extends ItemStates {}

class RequestingItem extends ItemStates {}

class RequestingPaginationItem extends ItemStates {}

class ItemData extends ItemStates {
  final List<dynamic> entities;

  const ItemData(this.entities);
}

class ItemError extends ItemStates {
  final String message;

  const ItemError(this.message);
}
