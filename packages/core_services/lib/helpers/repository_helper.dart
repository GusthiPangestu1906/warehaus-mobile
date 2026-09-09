import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:core_services/error/failure.dart';

mixin RepositoryHelper {
  Future<Either<Failure, T>> execute<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on DioException catch (e) {
      return Left(_failureFromDio(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _failureFromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    if (e.type == DioExceptionType.badResponse) {
      final responseData = e.response?.data;
      String errorMessage = 'Terjadi kesalahan validasi (400).';

      if (responseData is Map<String, dynamic>) {
        errorMessage =
            responseData['error_description']?.toString() ??
            responseData['detail']?.toString() ??
            responseData['message']?.toString() ??
            _extractValidationErrors(responseData) ??
            errorMessage;
      }

      return BadRequestFailure(errorMessage);
    }

    return ServerFailure();
  }

  String? _extractValidationErrors(Map<String, dynamic> responseData) {
    final errors = responseData['errors'];
    if (errors is! Map) return null;

    final messages = <String>[];
    errors.forEach((field, value) {
      if (value is List) {
        messages.addAll(value.map((message) => '$field: $message'));
      } else if (value != null) {
        messages.add('$field: $value');
      }
    });

    return messages.isEmpty ? null : messages.join('\n');
  }
}
