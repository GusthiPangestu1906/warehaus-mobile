import 'package:core_services/interceptors/auth/auth_interceptor.dart';
import 'package:core_services/interceptors/error/error_interceptor.dart';
import 'package:core_services/storage/auth_token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  late final Dio dio;
  late final Dio refreshDio;
  final AuthTokenStorage tokenStorage;

  ApiClient({required this.tokenStorage, void Function()? onSessionExpired}) {
    final configuredBaseUrl = dotenv.get('API_URL').trim();
    final baseUrl = _resolveBaseUrl(configuredBaseUrl);
    debugPrint('[ApiClient] baseUrl=$baseUrl');

    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      headers: const {
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      },
    );

    dio = Dio(baseOptions);
    refreshDio = Dio(baseOptions);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.path.startsWith('/api/') &&
              !options.path.startsWith('api/')) {
            if (options.path.startsWith('/')) {
              options.path = options.path;
            } else {
              options.path = options.path;
            }
          }
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        storage: tokenStorage,
        refreshDio: refreshDio,
        onSessionExpired: onSessionExpired,
      ),
    );

    dio.interceptors.add(ErrorInterceptor());
    dio.interceptors.add(LogInterceptor(requestBody: true));
  }

  String _resolveBaseUrl(String configuredBaseUrl) {
    final uri = Uri.tryParse(configuredBaseUrl);
    if (uri == null) {
      return configuredBaseUrl;
    }

    if (kIsWeb && uri.scheme == 'https' && uri.host == 'localhost') {
      return uri.replace(scheme: 'http').toString();
    }

    return configuredBaseUrl;
  }
}
