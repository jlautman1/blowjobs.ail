import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final String? token;
  final int matchCount;
  final int unreadMessages;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.token,
    this.matchCount = 0,
    this.unreadMessages = 0,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    String? token,
    int? matchCount,
    int? unreadMessages,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      token: token ?? this.token,
      matchCount: matchCount ?? this.matchCount,
      unreadMessages: unreadMessages ?? this.unreadMessages,
    );
  }
  
  String get userType => user?['user_type'] ?? 'job_seeker';
  String get firstName => user?['first_name'] ?? '';
  String get email => user?['email'] ?? '';
  String get userId => user?['id'] ?? '';
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        _apiService.setAuthToken(token);
        final user = await _apiService.getCurrentUser();
        state = AuthState(
          isAuthenticated: true,
          token: token,
          user: user,
        );
      } else {
        state = AuthState(isAuthenticated: false);
      }
    } catch (e) {
      state = AuthState(isAuthenticated: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.login(email, password);
      final token = response['token'];
      final user = response['user'];
      
      await _storageService.saveToken(token);
      _apiService.setAuthToken(token);
      
      state = AuthState(
        isAuthenticated: true,
        token: token,
        user: user,
      );
      return true;
    } catch (e) {
      // Clean up the error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      // Explicitly set isAuthenticated to false to prevent router from redirecting to home
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> register(String email, String password, String firstName, String userType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.register(email, password, firstName, userType);
      final token = response['token'];
      final user = response['user'];
      
      await _storageService.saveToken(token);
      _apiService.setAuthToken(token);
      
      state = AuthState(
        isAuthenticated: true,
        token: token,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearToken();
    _apiService.clearAuthToken();
    state = AuthState(isAuthenticated: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService(ref));

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(apiService, storageService);
});

