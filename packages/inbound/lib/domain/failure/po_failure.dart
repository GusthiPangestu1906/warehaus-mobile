import 'package:core_services/core_services.dart';

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'An error occurred on the server. Please try again later.',
  }) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message =
        'No internet connection. Please check your network settings and try again.',
  }) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Unauthorized access. Please log in again.',
  }) : super(message);
}
