abstract class ServerExceptions implements Exception {
  final String message;
  final int? statusCode;

  const ServerExceptions(this.message, this.statusCode);

  @override
  String toString() => "ServerException: $message (StatusCode: $statusCode)";
}

class UnauthorizedException extends ServerExceptions {
  const UnauthorizedException([
    String message = "Sesi telah berakhir, silahkan login kembali",
  ]) : super(message, 401);
}

class BadRequestException extends ServerExceptions {
  const BadRequestException([String message = "Permintaan tidak valid"])
    : super(message, 400);
}

class NotFoundException extends ServerExceptions {
  const NotFoundException([String message = "Data tidak ditemukan"])
    : super(message, 404);
}

class ServerConflictException extends ServerExceptions {
  const ServerConflictException([
    String message = "Data sudah ada atau konflik",
  ]) : super(message, 409);
}

class ServerForbiddenException extends ServerExceptions {
  const ServerForbiddenException([
    String message =
        "Anda tidak memiliki hak akses untuk melakukan operasi ini",
  ]) : super(message, 403);
}

class InternalServerException extends ServerExceptions {
  const InternalServerException([String message = "Terjadi kesalahan server"])
    : super(message, 500);
}

class ServiceUnavailableException extends ServerExceptions {
  const ServiceUnavailableException([String message = "Layanan tidak tersedia"])
    : super(message, 503);
}
