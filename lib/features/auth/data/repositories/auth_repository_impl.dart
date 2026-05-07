import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl() : _datasource = AuthRemoteDatasource();

  @override
  Stream<UserModel?> get authStateChanges => _datasource.authStateChanges;

  @override
  UserModel? get currentUser => null; // Se obtiene via provider

  @override
  Future<Either<Failure, UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _datasource.signIn(email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpClient({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final user = await _datasource.signUpClient(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpProvider({
    required String email,
    required String password,
    required String fullName,
    required String categorySlug,
    required int yearsExperience,
    required String bio,
    String? phone,
  }) async {
    try {
      final user = await _datasource.signUpProvider(
        email: email,
        password: password,
        fullName: fullName,
        categorySlug: categorySlug,
        yearsExperience: yearsExperience,
        bio: bio,
        phone: phone,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _datasource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset({
    required String email,
  }) async {
    try {
      await _datasource.sendPasswordReset(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> fetchCurrentUser() async {
    try {
      final user = await _datasource.fetchCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
