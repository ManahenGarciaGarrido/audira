import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/mock_data_repository.dart';
import '../../data/models/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MockDataRepository repository;

  AuthBloc(this.repository) : super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    await Future.delayed(const Duration(seconds: 1));

    // Simular login exitoso
    final mockUser = UserModel(
      id: 'user1',
      email: event.email,
      name: 'Usuario Demo',
      username: 'demo_user',
      role: UserRole.member,
      profileImage: 'https://via.placeholder.com/150/673AB7/FFFFFF?text=U',
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(status: AuthStatus.authenticated, user: mockUser));
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    await Future.delayed(const Duration(seconds: 1));

    final mockUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: event.email,
      name: event.name,
      role: event.role,
      birthDate: event.birthDate,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(status: AuthStatus.authenticated, user: mockUser));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Simular usuario invitado por defecto
    if (state.status == AuthStatus.initial) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }
}
