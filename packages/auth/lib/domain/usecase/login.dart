import 'package:auth/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository _repository;

  Login(this._repository);

  Future<void> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
