import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_model.dart';

abstract class AuthRepository {
  /// Stream del estado de autenticación
  Stream<UserModel?> get authStateChanges;

  /// Usuario actual en sesión
  UserModel? get currentUser;

  /// Iniciar sesión con email y contraseña
  Future<Either<Failure, UserModel>> signIn({
    required String email,
    required String password,
  });

  /// Registrar cliente
  Future<Either<Failure, UserModel>> signUpClient({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  /// Registrar prestador
  Future<Either<Failure, UserModel>> signUpProvider({
    required String email,
    required String password,
    required String fullName,
    required String categorySlug,
    required int yearsExperience,
    required String bio,
    String? phone,
  });

  /// Cerrar sesión
  Future<Either<Failure, void>> signOut();

  /// Enviar email de recuperación de contraseña
  Future<Either<Failure, void>> sendPasswordReset({required String email});

  /// Obtener perfil completo del usuario actual desde DB
  Future<Either<Failure, UserModel>> fetchCurrentUser();
}
