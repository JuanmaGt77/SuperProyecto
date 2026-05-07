import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Repository provider ──────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// ── Auth state ───────────────────────────────────────────────────────────────
enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

// ── AuthNotifier ─────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    _repo.authStateChanges.listen(
      (user) {
        if (user != null) {
          state = AuthState(status: AuthStatus.authenticated, user: user);
        } else {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      },
      onError: (_) {
        // Only reset if we don't already have an authenticated user.
        // Avoids undoing a successful signIn/signUp when the profile
        // fetch in asyncMap races against Supabase DB triggers.
        if (!state.isAuthenticated) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  // Called by SplashScreen to resolve the initial auth state
  Future<void> initialize() async {
    if (state.status != AuthStatus.loading) return;
    final result = await _repo.fetchCurrentUser().timeout(
      const Duration(seconds: 6),
      onTimeout: () => const Left(UnexpectedFailure('Timeout')),
    );
    result.fold(
      (_) => state = const AuthState(status: AuthStatus.unauthenticated),
      (user) => state = AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    final result = await _repo.signIn(email: email, password: password);
    return result.fold(
      (failure) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> signUpClient({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    final result = await _repo.signUpClient(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    return result.fold(
      (failure) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> signUpProvider({
    required String email,
    required String password,
    required String fullName,
    required String categorySlug,
    required int yearsExperience,
    required String bio,
    String? phone,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    final result = await _repo.signUpProvider(
      email: email,
      password: password,
      fullName: fullName,
      categorySlug: categorySlug,
      yearsExperience: yearsExperience,
      bio: bio,
      phone: phone,
    );
    return result.fold(
      (failure) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> sendPasswordReset({required String email}) async {
    final result = await _repo.sendPasswordReset(email: email);
    return result.fold((_) => false, (_) => true);
  }

  Future<void> refreshUser() async {
    final result = await _repo.fetchCurrentUser();
    result.fold(
      (_) {},
      (user) => state = state.copyWith(user: user),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ── Provider principal ───────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// ── Providers derivados (conveniencia) ───────────────────────────────────────
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});
