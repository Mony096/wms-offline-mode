part of 'authorization_bloc.dart';

abstract class AuthorizationState extends Equatable {
  const AuthorizationState();

  @override
  List<Object> get props => [];
}

class AuthorizationInitial extends AuthorizationState {}

class RequestLoginFailedState extends AuthorizationState {
  final String message;

  const RequestLoginFailedState({required this.message});
}

class UnAuthorization extends AuthorizationState {}

class RequestingAuthorization extends AuthorizationState {}

class AuthorizationSuccess extends AuthorizationState {
  
}
