class ApiException implements Exception {
  final String message;
  final String? title;
  final int? statusCode;

  ApiException({required this.message, this.title, this.statusCode});

  @override
  String toString() => message;
}
