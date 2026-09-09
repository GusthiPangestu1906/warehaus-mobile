import 'dart:convert';

import 'package:auth/data/datasources/auth_remote_datasource.dart';
import 'package:auth/domain/entities/user_session.dart';
import 'package:auth/domain/repositories/auth_repository.dart';
import 'package:core_services/core_services.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl with RepositoryHelper implements AuthRepository {
  final AuthRemoteDatasource _authRemoteDatasource;
  final AuthTokenStorage _authTokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDatasource authRemoteDatasource,
    required AuthTokenStorage authTokenStorage,
  }) : _authRemoteDatasource = authRemoteDatasource,
       _authTokenStorage = authTokenStorage;

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) {
    return execute(() async {
      final tokenData = await _authRemoteDatasource.login(
        email: email,
        password: password,
      );
      await _authTokenStorage.saveTokens(
        accessToken: tokenData.accessToken,
        refreshToken: tokenData.refreshToken ?? '',
      );

      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return execute(() async {
      await _authTokenStorage.clearTokens();
      return unit;
    });
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() {
    return execute(() async {
      return await _authTokenStorage.hasToken();
    });
  }

  @override
  Future<Either<Failure, UserSession?>> getCurrentUser() {
    return execute(() async {
      final token = await _authTokenStorage.getAccessToken();
      if (token == null || token.isEmpty) return null;

      // Hapus try-catch manual, karena execute() sudah menangani Exception
      // Jika token korup (gagal di-decode), execute akan mengembalikan Left(ServerFailure)
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payload = jsonDecode(payloadString);

      final rawRoles = payload['roles'];
      final List<String> roles = rawRoles is List
          ? List<String>.from(rawRoles)
          : (rawRoles != null ? [rawRoles.toString()] : []);

      final rawPermissions = payload['permissions'];
      final List<String> permissions = rawPermissions is List
          ? List<String>.from(rawPermissions)
          : (rawPermissions != null ? [rawPermissions.toString()] : []);

      return UserSession(
        userId: payload['sub'] ?? '',
        name: payload['name'] ?? '',
        email: payload['email'] ?? '',
        roles: roles,
        permissions: permissions,
      );
    });
  }
}
