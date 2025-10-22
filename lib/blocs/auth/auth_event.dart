import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final DateTime? birthDate;
  final UserRole role;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.birthDate,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, birthDate, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}
