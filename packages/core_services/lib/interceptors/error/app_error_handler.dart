import 'package:core_services/interceptors/error/api_exception.dart';
import 'package:dio/dio.dart';

class AppErrorHandler {
  static String extractMessage(Object e) {
    if (e is DioException) {
      if (e.error is ApiException) {
        return (e.error as ApiException).message;
      }
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['detail'] ?? data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server.';
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Server tidak merespons. Coba lagi nanti.';
      }
    }
    if (e is ApiException) return e.message;
    return e.toString();
  }
}
