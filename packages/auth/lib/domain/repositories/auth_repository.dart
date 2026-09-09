import 'package:auth/domain/entities/user_session.dart';
import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, UserSession?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
}
