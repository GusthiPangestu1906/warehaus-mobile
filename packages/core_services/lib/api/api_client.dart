import 'package:core_services/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    final configuredBaseUrl = dotenv.get('API_URL').trim();
    final baseUrl = _resolveBaseUrl(configuredBaseUrl);

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        headers: const {'ngrok-skip-browser-warning': 'true'},
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
