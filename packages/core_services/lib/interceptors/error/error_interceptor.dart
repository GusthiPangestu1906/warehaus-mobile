import 'package:core_services/interceptors/error/api_exception.dart';
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi nanti.';
    String? errorTitle;
    final statusCode = err.response?.statusCode;

    if (err.response?.data != null && err.response?.data is Map) {
      final data = err.response!.data;
      errorMessage = data['detail'] ?? data['message'] ?? errorMessage;
      errorTitle = data['title'];
    } else {
      if (err.type == DioExceptionType.connectionError) {
        errorMessage =
            'Tidak dapat terhubung ke server. Jika menggunakan Flutter Web, pastikan URL API benar, server aktif, dan CORS/HTTPS lokal sudah sesuai.';
      } else if (err.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Server tidak merespons.(Timeout) Silakan coba lagi nanti.';
      } else if (err.type == DioExceptionType.badResponse) {
        if (statusCode != null && statusCode >= 500) {
          errorMessage =
              'Server sedang bermasalah (HTTP $statusCode). Periksa service API dan koneksi database backend.';
        } else if (statusCode == 404) {
          errorMessage = 'Endpoint API tidak ditemukan (404).';
        } else if (statusCode != null) {
          errorMessage = 'Permintaan gagal dengan status HTTP $statusCode.';
        }
      }
    }
    final apiException = ApiException(
      message: errorMessage,
      title: errorTitle,
      statusCode: statusCode,
    );
    handler.next(err.copyWith(error: apiException));
  }
}
