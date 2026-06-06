import 'package:core_services/interceptors/api_exception.dart';
import 'package:dio/dio.dart';

class AppErrorHandler {
  /// Ekstrak pesan error yang bersih dari exception apapun.
  static String extractMessage(Object e) {
    if (e is DioException) {
      // 1. Cek apakah ada ApiException di dalam e.error
      final dynamic nestedError = e.error;
      if (nestedError is ApiException) {
        return nestedError.message;
      }

      // 2. Fallback ke response data dari server
      final data = e.response?.data;
      if (data is Map) {
        // Menambahkan opsi 'error' dan 'errors' yang sering dipakai di backend
        final msg = data['detail'] ?? data['message'] ?? data['error'];
        if (msg is String && msg.isNotEmpty) return msg;

        // Jika error berbentuk list (contoh dari Laravel/projek lain)
        if (data['errors'] is Map) {
          final firstError = (data['errors'] as Map).values.first;
          if (firstError is List && firstError.isNotEmpty)
            return firstError.first.toString();
          if (firstError is String) return firstError;
        }
      }

      // 3. Fallback berdasarkan tipe DioException
      switch (e.type) {
        case DioExceptionType.connectionError:
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi lambat. Server tidak merespons, silakan coba lagi.';
        case DioExceptionType.badResponse:
          return 'Terjadi kesalahan pada server (${e.response?.statusCode}).';
        case DioExceptionType.cancel:
          return 'Permintaan dibatalkan.';
        case DioExceptionType.unknown:
        default:
          // Biasanya SocketException (internet mati) bersembunyi di sini
          if (e.message?.contains('SocketException') ?? false) {
            return 'Tidak ada koneksi internet.';
          }
          return 'Terjadi kesalahan tidak diketahui.';
      }
    }

    // 4. Jika error langsung berupa ApiException
    if (e is ApiException) return e.message;

    // 5. Fallback terakhir
    return e.toString();
  }
}
