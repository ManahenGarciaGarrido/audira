import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../api/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get userRole => _currentUser?.role ?? 'GUEST';

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      _currentUser = await _authService.getCurrentUser();
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String emailOrUsername, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
          'AUTH_PROVIDER: Llamando a _authService.login...'); // <-- AÑADE ESTO

      final response = await _authService.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      print(
          'AUTH_PROVIDER: _authService.login HA TERMINADO.'); // <-- AÑADE ESTO

      if (response.success && response.data != null) {
        _currentUser = response.data!.user;
        _isAuthenticated = true;
        return true;
      } else {
        _error = response.error;
        return false;
      }
    } catch (e) {
      print('AUTH_PROVIDER: Excepción capturada: $e'); // <-- AÑADE ESTO
      _error = 'Ocurrió un error inesperado. Revisa tu conexión.';
      return false;
    } finally {
      print('AUTH_PROVIDER: Bloque FINALLY ejecutado.'); // <-- AÑADE ESTO
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? artistName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _authService.register(
      email: email,
      username: username,
      password: password,
      role: role,
      firstName: firstName,
      lastName: lastName,
      artistName: artistName,
    );

    if (response.success && response.data != null) {
      _currentUser = response.data!.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final response = await _authService.getProfile();
    if (response.success && response.data != null) {
      _currentUser = response.data;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
