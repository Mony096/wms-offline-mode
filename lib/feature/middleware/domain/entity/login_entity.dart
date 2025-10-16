import 'package:equatable/equatable.dart';

class LoginEntity extends Equatable {
  final String username;
  final String password;
  final String db;

  const LoginEntity(
      {required this.username, required this.password, required this.db});

  @override
  List<Object?> get props => [];
}
