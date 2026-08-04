import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../domain/user.dart';
import '../data/auth_repository.dart';
import 'package:cookie_jar/cookie_jar.dart';

// State wrapper for auth
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});
  
  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearError = false}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  CookieJar get _cookieJar => ref.read(cookieJarProvider);

  @override
  AuthState build() {
    Future.microtask(_init);
    return const AuthState(isLoading: true);
  }

  Future<void> _init() async {
    try {
      final hasSession = await _storage.read(key: 'has_session');
      if (hasSession == 'true') {
        final user = await _repository.me();
        state = AuthState(user: user, isLoading: false);
      } else {
        state = const AuthState(isLoading: false);
      }
    } on DioException catch (e) {
      // Typically on 401 we clear token.
      if (e.response?.statusCode == 401) {
        await _storage.delete(key: 'has_session');
        await _cookieJar.deleteAll(); // Clear expired cookies
      }
      state = AuthState(isLoading: false, error: 'Session expired or offline');
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email, password);
      // Since backend relies on HttpOnly cookies, we just save a flag indicating we have an active session
      // For mobile, dio_cookie_manager will handle the cookie. For web, the browser handles it.
      await _storage.write(key: 'has_session', value: 'true');
      
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      String errorMessage = 'Login failed: $e';
      if (e is DioException) {
        if (e.response != null) {
          errorMessage = 'Server error: ${e.response?.statusCode} - ${e.response?.data}';
        } else {
          errorMessage = 'Network error: ${e.message}';
        }
      }
      state = AuthState(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    await _storage.delete(key: 'has_session');
    await _cookieJar.deleteAll(); // Clear persistent cookies
    state = const AuthState(isLoading: false);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repository.me();
      state = state.copyWith(user: user);
    } catch (e) {
      // Ignored for refresh purposes
    }
  }

  // A method for developers to bypass login when backend is offline
  void developerBypass() {
    final devUser = User(
      id: 'dev-id-123',
      username: 'Developer Admin',
      email: 'admin@bumbleerp.com',
      roles: ['ROLE_SUPER_ADMIN'],
      organizationName: 'BumbleERP Dev',
      effectivePermissions: [
        'ticket.view', 'role.view', 'user.view', 'sales.view', 
        'finance.view', 'employee.view', 'department.view', 'designation.view', 'payroll.view', 'approvals.view'
      ],
    );
    state = AuthState(user: devUser, isLoading: false);
  }

  // Toggle between HR and Employee roles for testing the UI
  void toggleDeveloperRole() {
    if (state.user == null) return;
    
    final currentUser = state.user!;
    final isCurrentlyHR = currentUser.roles.contains('ROLE_SUPER_ADMIN') || currentUser.roles.contains('ROLE_HR');
    
    final newUser = currentUser.copyWith(
      roles: isCurrentlyHR ? ['ROLE_EMPLOYEE'] : ['ROLE_SUPER_ADMIN'],
      effectivePermissions: isCurrentlyHR ? [] : [
        'ticket.view', 'role.view', 'user.view', 'sales.view', 
        'finance.view', 'employee.view', 'department.view', 'designation.view', 'payroll.view', 'approvals.view'
      ],
    );
    
    state = state.copyWith(user: newUser);
  }
}
