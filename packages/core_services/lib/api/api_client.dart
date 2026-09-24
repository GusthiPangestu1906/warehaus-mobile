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

    final pathInterceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!options.path.startsWith('http://') &&
            !options.path.startsWith('https://')) {
          if (!options.path.startsWith('/api/') &&
              !options.path.startsWith('api/')) {
            final cleanPath = options.path.startsWith('/')
                ? options.path.substring(1)
                : options.path;
            options.path = '/api/$cleanPath';
          }
        }
        return handler.next(options);
      },
    );

    dio.interceptors.add(pathInterceptor);
    refreshDio.interceptors.add(pathInterceptor);

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
    var url = configuredBaseUrl.trim();
    if (url.endsWith('/api')) {
      url = url.substring(0, url.length - 4);
    } else if (url.endsWith('/api/')) {
      url = url.substring(0, url.length - 5);
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return url;
    }

    if (kIsWeb && uri.scheme == 'https' && uri.host == 'localhost') {
      return uri.replace(scheme: 'http').toString();
    }

    return url;
  }
}
