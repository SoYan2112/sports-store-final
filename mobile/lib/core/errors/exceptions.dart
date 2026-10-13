class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại kết nối.'});

  @override
  String toString() => 'NetworkException: $message';
}
