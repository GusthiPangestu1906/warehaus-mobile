import 'package:auth/domain/repositories/auth_repository.dart';
import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';

class Logout {
  final AuthRepository _repository;

  Logout(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.logout();
  }
}
