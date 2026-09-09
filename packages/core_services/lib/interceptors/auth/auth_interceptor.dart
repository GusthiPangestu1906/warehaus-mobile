import 'package:core_services/storage/auth_token_storage.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenStorage _storage;
  final Dio _refreshDio;
  final Function()? onSessionExpired;

  AuthInterceptor({
    required AuthTokenStorage storage,
    required Dio refreshDio,
    required this.onSessionExpired,
  }) : _storage = storage,
       _refreshDio = refreshDio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.path.contains('/connect/token')) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/connect/token')) {
      final isRefreshed = await _tryRefreshToken();

      if (isRefreshed) {
        final newToken = await _storage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await _refreshDio.fetch(err.requestOptions);
          handler.resolve(response);
        } on DioException catch (e) {
          onSessionExpired?.call();
          return handler.next(e);
        }
      } else {
        await _storage.clearTokens();
      }
    }
    handler.reject(err);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _refreshDio.post(
        '/connect/token',
        data: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        await _storage.saveTokens(
          accessToken: response.data['access_token'] as String,
          refreshToken: response.data['refresh_token'] as String,
        );
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
