import 'package:auth/domain/repositories/auth_repository.dart';
import 'package:core_services/error/failure.dart';
import 'package:dartz/dartz.dart';

class Login {
  final AuthRepository _repository;

  Login(this._repository);

  Future<Either<Failure, Unit>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
