import 'package:auth/domain/entities/user_session.dart';
import 'package:auth/domain/repositories/auth_repository.dart';

class CheckAuth {
  final AuthRepository _repository;

  CheckAuth(this._repository);

  Future<UserSession?> call() async {
    final isAuth = await _repository.isAuthenticated();
    if (!isAuth) return null;
    return _repository.getCurrentUser();
  }
}
