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
      return _fetchUserProfile(user.id);
    });
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

      // Wait for handle_new_user trigger
      await Future.delayed(const Duration(milliseconds: 1500));

      // Try to update phone — non-critical, don't fail if it errors
      if (phone != null && phone.isNotEmpty) {
        try {
          await _client.from('users').update({'phone': phone}).eq('id', userId);
        } catch (e) {
          debugPrint('[Auth] signUpClient: phone update failed (non-fatal): $e');
        }
      }

      // Try to create client_profile — non-critical
      try {
        await _client.from('client_profiles').upsert({'user_id': userId});
        debugPrint('[Auth] signUpClient: client_profile created');
      } catch (e) {
        debugPrint('[Auth] signUpClient: client_profile failed (non-fatal): $e');
      }

      return _fetchUserProfileWithRetry(userId);
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AppAuthException(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('[Auth] signUpClient ERROR: $e');
      throw AppAuthException('Error al registrarse: $e');
    }
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

      await Future.delayed(const Duration(milliseconds: 1500));

      // Update role — non-critical
      try {
        await _client.from('users').update({
          'role': 'provider',
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }).eq('id', userId);
      } catch (e) {
        debugPrint('[Auth] signUpProvider: role update failed (non-fatal): $e');
      }

      // Create provider_profile — critical for provider flow
      String? providerId;
      try {
        final profileRes = await _client
            .from('provider_profiles')
            .insert({'user_id': userId, 'bio': bio, 'years_experience': yearsExperience})
            .select()
            .single();
        providerId = profileRes['id'] as String;
        debugPrint('[Auth] signUpProvider: provider_profile created $providerId');
      } catch (e) {
        debugPrint('[Auth] signUpProvider: provider_profile failed (non-fatal): $e');
      }

      // Link category — non-critical
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
          debugPrint('[Auth] signUpProvider: category link failed (non-fatal): $e');
        }
      }

      return _fetchUserProfileWithRetry(userId);
    } on AppAuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AppAuthException(_mapAuthError(e.message));
    } catch (e) {
      debugPrint('[Auth] signUpProvider ERROR: $e');
      throw AppAuthException('Error al registrarse como prestador: $e');
    }
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
    return _fetchUserProfile(userId);
  }

  Future<UserModel> _fetchUserProfileWithRetry(String userId) async {
    // Retry up to 4 times with 1s between attempts (trigger may be slow)
    for (var attempt = 1; attempt <= 4; attempt++) {
      try {
        final data = await _client.from('users').select().eq('id', userId).single();
        debugPrint('[Auth] fetchUserProfile: found on attempt $attempt');
        return UserModel.fromJson(data);
      } catch (e) {
        debugPrint('[Auth] fetchUserProfile attempt $attempt failed: $e');
        if (attempt < 4) await Future.delayed(const Duration(milliseconds: 1000));
      }
    }
    throw const ServerException('No se pudo obtener el perfil. Verifica que el schema esté aplicado en Supabase.');
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
    if (m.contains('email already registered') || m.contains('already been registered')) {
      return 'Este correo ya está registrado';
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
