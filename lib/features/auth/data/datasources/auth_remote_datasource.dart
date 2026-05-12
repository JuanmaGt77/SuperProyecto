import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../../../shared/models/user_model.dart';

class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource() : _client = SupabaseConfig.client;

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      try {
        return await _fetchUserProfile(user.id);
      } catch (_) {
        // DB trigger hasn't run yet — build model from auth metadata
        return _userModelFromAuthUser(user);
      }
    });
  }

  UserModel _userModelFromAuthUser(User user) {
    final meta = user.userMetadata ?? {};
    final now = DateTime.now();
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: meta['full_name'] as String? ??
          (user.email?.split('@').first ?? 'Usuario'),
      phone: meta['phone'] as String?,
      role: UserRoleExt.fromString(meta['role'] as String? ?? 'client'),
      isActive: true,
      isBlocked: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AppAuthException('No se pudo iniciar sesión');
      }
      return _fetchUserProfile(response.user!.id);
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AppAuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AppAuthException('Error al iniciar sesión: $e');
    }
  }

  Future<UserModel> signUpClient({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'client',
          if (phone != null) 'phone': phone,
        },
      );
      if (response.user == null) {
        throw const AppAuthException('No se pudo crear la cuenta');
      }
      final userId = response.user!.id;
      debugPrint('[Auth] signUpClient: user created $userId');

      // Return immediately from auth metadata — no need to wait for the
      // handle_new_user DB trigger. Profile tables are set up in background.
      _setupClientProfileInBackground(userId, phone);

      return _userModelFromAuthUser(response.user!);
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AppAuthException(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('[Auth] signUpClient ERROR: $e');
      throw AppAuthException('Error al registrarse: $e');
    }
  }

  void _setupClientProfileInBackground(String userId, String? phone) {
    Future.microtask(() async {
      // Give the handle_new_user trigger time to create the users row
      await Future.delayed(const Duration(milliseconds: 2000));
      if (phone != null && phone.isNotEmpty) {
        try {
          await _client.from('users').update({'phone': phone}).eq('id', userId);
        } catch (e) {
          debugPrint('[Auth] bg phone update failed: $e');
        }
      }
      try {
        await _client.from('client_profiles').upsert({'user_id': userId});
        debugPrint('[Auth] bg client_profile created');
      } catch (e) {
        debugPrint('[Auth] bg client_profile failed: $e');
      }
    });
  }

  Future<UserModel> signUpProvider({
    required String email,
    required String password,
    required String fullName,
    required String categorySlug,
    required int yearsExperience,
    required String bio,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'provider',
          if (phone != null) 'phone': phone,
        },
      );
      if (response.user == null) {
        throw const AppAuthException('No se pudo crear la cuenta');
      }

      final userId = response.user!.id;
      debugPrint('[Auth] signUpProvider: user created $userId');

      // Return immediately; set up provider profile tables in background.
      _setupProviderProfileInBackground(
        userId: userId,
        phone: phone,
        bio: bio,
        yearsExperience: yearsExperience,
        categorySlug: categorySlug,
      );

      return _userModelFromAuthUser(response.user!);
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AppAuthException(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('[Auth] signUpProvider ERROR: $e');
      throw AppAuthException('Error al registrarse como prestador: $e');
    }
  }

  void _setupProviderProfileInBackground({
    required String userId,
    String? phone,
    required String bio,
    required int yearsExperience,
    required String categorySlug,
  }) {
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 2000));

      try {
        await _client.from('users').update({
          'role': 'provider',
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }).eq('id', userId);
      } catch (e) {
        debugPrint('[Auth] bg provider role update failed: $e');
      }

      String? providerId;
      try {
        final profileRes = await _client
            .from('provider_profiles')
            .insert({'user_id': userId, 'bio': bio, 'years_experience': yearsExperience})
            .select()
            .single();
        providerId = profileRes['id'] as String;
        debugPrint('[Auth] bg provider_profile created $providerId');
      } catch (e) {
        debugPrint('[Auth] bg provider_profile failed: $e');
      }

      if (providerId != null) {
        try {
          final categoryRes = await _client
              .from('service_categories')
              .select('id')
              .eq('slug', categorySlug)
              .maybeSingle();
          if (categoryRes != null) {
            await _client.from('provider_categories').insert({
              'provider_id': providerId,
              'category_id': categoryRes['id'],
              'is_primary': true,
            });
          }
        } catch (e) {
          debugPrint('[Auth] bg category link failed: $e');
        }
      }
    });
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException('Error al cerrar sesión: $e');
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      throw AppAuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AppAuthException('Error al enviar el correo: $e');
    }
  }

  Future<UserModel> fetchCurrentUser() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw const AppAuthException('Sin sesión activa');
    try {
      return await _fetchUserProfile(userId);
    } catch (_) {
      final authUser = _client.auth.currentUser;
      if (authUser != null) return _userModelFromAuthUser(authUser);
      rethrow;
    }
  }

  Future<UserModel> _fetchUserProfile(String userId) async {
    try {
      final data = await _client.from('users').select().eq('id', userId).single();
      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('[Auth] _fetchUserProfile ERROR for $userId: $e');
      throw ServerException('No se pudo obtener el perfil del usuario: $e');
    }
  }

  String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') || m.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (m.contains('email already registered') || m.contains('already been registered') ||
        m.contains('user already registered')) {
      return 'Este correo ya tiene una cuenta. Intenta iniciar sesión.';
    }
    if (m.contains('email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión';
    }
    if (m.contains('too many requests')) {
      return 'Demasiados intentos. Espera un momento';
    }
    if (m.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return message;
  }
}
