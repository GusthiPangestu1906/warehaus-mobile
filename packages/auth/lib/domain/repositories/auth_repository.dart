import 'package:auth/domain/entities/user_session.dart';

abstract class AuthRepository {
  Future<void> login({required String email, required String password});
  Future<void> logout();
  Future<UserSession?> getCurrentUser();
  Future<bool> isAuthenticated();
}
