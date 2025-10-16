import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  String getErrorMessage() {
    return message;
  }
}

class ConnectionRefuse extends Failure {
  const ConnectionRefuse({required String message}) : super(message: message);

  @override
  List<Object?> get props => throw UnimplementedError();
}

class MappingFieldError extends Failure {
  const MappingFieldError({required String message}) : super(message: message);

  @override
  List<Object?> get props => [message];
}

class HttpError extends Failure {
  const HttpError({required String message}) : super(message: message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});

  @override
  List<Object?> get props => [message];
}

class UnauthorizeFailure extends Failure {
  const UnauthorizeFailure({required super.message});

  @override
  List<Object?> get props => [message];
}
