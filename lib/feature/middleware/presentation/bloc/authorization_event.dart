part of 'authorization_bloc.dart';

abstract class AuthorizationEvent extends Equatable {
  const AuthorizationEvent();

  @override
  List<Object> get props => [];
}

class RequestLoginOnlineEvent extends AuthorizationEvent {
  final LoginEntity entity;

  const RequestLoginOnlineEvent({required this.entity});
}
class RequestLoginOfflineEvent extends AuthorizationEvent {
  final LoginEntity entity;

  const RequestLoginOfflineEvent({required this.entity});
}

class RequestLogoutEvent extends AuthorizationEvent {
  const RequestLogoutEvent();
}
