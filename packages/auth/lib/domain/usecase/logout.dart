import 'package:auth/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository _repository;

  Logout(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}
