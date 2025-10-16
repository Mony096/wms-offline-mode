part of 'delivery_cubit.dart';

class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object> get props => [];
}

class DeliveryInitial extends DeliveryState {}

class RequestingDelivery extends DeliveryState {}

class RequestingPaginationDelivery extends DeliveryState {}

class DeliveryData extends DeliveryState {
  final Map<String, dynamic> entities;

  const DeliveryData(this.entities);
}

class DeliveryError extends DeliveryState {
  final String message;

  const DeliveryError(this.message);
}
