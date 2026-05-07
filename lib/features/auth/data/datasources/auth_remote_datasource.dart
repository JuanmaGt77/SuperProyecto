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
        throw const AuthException('No se pudo iniciar sesión');
      }
      return _fetchUserProfile(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Error al iniciar sesión: $e');
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
        throw const AuthException('No se pudo crear la cuenta');
      }
      // Esperar brevemente para que el trigger handle_new_user se ejecute
      await Future.delayed(const Duration(milliseconds: 800));

      // Actualizar phone si fue proporcionado
      if (phone != null && phone.isNotEmpty) {
        await _client
            .from('users')
            .update({'phone': phone})
            .eq('id', response.user!.id);
      }

      // Crear client_profile
      await _client.from('client_profiles').upsert({
        'user_id': response.user!.id,
      });

      return _fetchUserProfile(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Error al registrarse: $e');
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
        throw const AuthException('No se pudo crear la cuenta');
      }

      await Future.delayed(const Duration(milliseconds: 800));

      // Actualizar role en users (el trigger crea con role del metadata)
      await _client.from('users').update({
        'role': 'provider',
        if (phone != null) 'phone': phone,
      }).eq('id', response.user!.id);

      // Crear provider_profile
      final profileRes = await _client
          .from('provider_profiles')
          .insert({
            'user_id': response.user!.id,
            'bio': bio,
            'years_experience': yearsExperience,
          })
          .select()
          .single();

      final providerId = profileRes['id'] as String;

      // Buscar la categoría por slug
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

      return _fetchUserProfile(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Error al registrarse como prestador: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Error al enviar el correo: $e');
    }
  }

  Future<UserModel> fetchCurrentUser() async {
    final userId = SupabaseConfig.currentUserId;
    if (userId == null) throw const AuthException('Sin sesión activa');
    return _fetchUserProfile(userId);
  }

  Future<UserModel> _fetchUserProfile(String userId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
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
