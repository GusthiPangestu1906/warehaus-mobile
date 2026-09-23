import 'package:auth/data/datasources/auth_remote_datasource.dart';
import 'package:auth/data/models/user_profile.dart';
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
      await _authTokenStorage.saveUserProfile({
        'id': tokenData.user.id,
        'fullName': tokenData.user.fullName,
        'email': tokenData.user.email,
        'phoneNumber': tokenData.user.phoneNumber,
        'status': tokenData.user.status,
        'isOwner': tokenData.user.isOwner,
        'warehouseId': tokenData.user.warehouseId,
        'warehouseName': tokenData.user.warehouseName,
        'roles': tokenData.user.roles,
        'permissions': tokenData.user.permissions,
      });

      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return execute(() async {
      // Hapus token lokal DULU agar logout selalu berhasil
      // walaupun API call gagal atau timeout
      await _authTokenStorage.clearTokens();

      // Fire-and-forget: coba beritahu server, tapi tidak blokir logout
      try {
        await _authRemoteDatasource.logout();
      } catch (_) {
        // Abaikan error API — token sudah dihapus secara lokal
      }

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
  Future<Either<Failure, UserProfile?>> getCurrentUser() {
    return execute(() async {
      final token = await _authTokenStorage.getAccessToken();
      if (token == null || token.isEmpty) return null;

      final userJson = await _authTokenStorage.getUserProfile();
      if (userJson == null) return null;

      return UserProfile.fromJson(userJson);
    });
  }
}
