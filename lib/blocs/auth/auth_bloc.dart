import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/user_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserService _userService;

  AuthBloc({
    AuthService? authService,
    UserService? userService,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService(),
        super(const AuthState()) {
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

    try {
      // Login con backend real
      final response = await _authService.login(
        email: event.email,
        password: event.password,
      );

      // Obtener perfil completo del usuario
      final userProfile = await _userService.getCurrentUserProfile();

      // Crear modelo de usuario
      final user = UserModel(
        id: userProfile['id'] ?? response['id'] ?? '',
        email: userProfile['email'] ?? event.email,
        name: userProfile['name'] ?? '',
        username: userProfile['username'],
        role: _parseUserRole(userProfile['role'] ?? 'USER'),
        profileImage: userProfile['profileImage'],
        birthDate: userProfile['birthDate'] != null
            ? DateTime.parse(userProfile['birthDate'])
            : null,
        followedArtists: List<String>.from(
          userProfile['followedArtists'] ?? [],
        ),
        createdAt: userProfile['createdAt'] != null
            ? DateTime.parse(userProfile['createdAt'])
            : DateTime.now(),
      );

      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Registro con backend real
      final response = await _authService.register(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role.name.toUpperCase(),
        birthDate: event.birthDate,
      );

      // Obtener perfil completo del usuario
      final userProfile = await _userService.getCurrentUserProfile();

      // Crear modelo de usuario
      final user = UserModel(
        id: userProfile['id'] ?? response['id'] ?? '',
        email: userProfile['email'] ?? event.email,
        name: userProfile['name'] ?? event.name,
        username: userProfile['username'],
        role: event.role,
        profileImage: userProfile['profileImage'],
        birthDate: event.birthDate,
        followedArtists: List<String>.from(
          userProfile['followedArtists'] ?? [],
        ),
        createdAt: userProfile['createdAt'] != null
            ? DateTime.parse(userProfile['createdAt'])
            : DateTime.now(),
      );

      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.logout();
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        // Usuario tiene token, obtener perfil
        final userProfile = await _userService.getCurrentUserProfile();

        final user = UserModel(
          id: userProfile['id'] ?? '',
          email: userProfile['email'] ?? '',
          name: userProfile['name'] ?? '',
          username: userProfile['username'],
          role: _parseUserRole(userProfile['role'] ?? 'USER'),
          profileImage: userProfile['profileImage'],
          birthDate: userProfile['birthDate'] != null
              ? DateTime.parse(userProfile['birthDate'])
              : null,
          followedArtists: List<String>.from(
            userProfile['followedArtists'] ?? [],
          ),
          createdAt: userProfile['createdAt'] != null
              ? DateTime.parse(userProfile['createdAt'])
              : DateTime.now(),
        );

        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  UserRole _parseUserRole(String role) {
    switch (role.toUpperCase()) {
      case 'ARTIST':
        return UserRole.artist;
      case 'ADMIN':
        return UserRole.admin;
      case 'MEMBER':
      case 'USER':
        return UserRole.member;
      default:
        return UserRole.guest;
    }
  }
}
