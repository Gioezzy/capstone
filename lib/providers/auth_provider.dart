import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/models.dart';
import 'repository_providers.dart';
import 'settings_providers.dart';

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null;

  AuthState({this.user, this.token, this.isLoading = false, this.error});

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState(isLoading: true)) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final token = prefs.getString('auth_token');
      state = state.copyWith(token: token, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final tokenObj = await repo.login(username, password);
      
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('auth_token', tokenObj.accessToken);
      
      state = state.copyWith(token: tokenObj.accessToken, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(username, email, password);
      // Auto login setelah register
      await login(username, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updatePassword(oldPassword, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('auth_token');
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
