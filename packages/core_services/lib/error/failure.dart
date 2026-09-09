abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'An error occurred on the server. Please try again later.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Please check your network settings and try again.',
  ]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Unauthorized access. Please log in again.',
  ]);
}

class BadRequestFailure extends Failure {
  const BadRequestFailure([
    super.message = 'Invalid request. Please check your data and try again.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to save file on device']);
}
