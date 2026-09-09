import 'package:auth/domain/entities/user_session.dart';
import 'package:auth/domain/repositories/auth_repository.dart';
import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';

class CheckAuth {
  final AuthRepository _repository;

  CheckAuth(this._repository);

  Future<Either<Failure, UserSession?>> call() async {
    final authResult = await _repository.isAuthenticated();

    return await authResult.fold((failure) async => Left(failure), (
      isAuth,
    ) async {
      if (!isAuth) {
        return const Left(UnauthorizedFailure("Not Authenticated"));
      }
      return await _repository.getCurrentUser();
    });
  }
}
