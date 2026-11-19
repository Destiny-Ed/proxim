class AppException implements Exception {
  final String message;
  final int statusCode;
  final String? code;

  AppException(this.message, {this.statusCode = 400, this.code});

  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, statusCode: 404, code: 'NOT_FOUND');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized'])
      : super(message, statusCode: 401, code: 'UNAUTHORIZED');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, statusCode: 422, code: 'VALIDATION');
}

class ConflictException extends AppException {
  ConflictException(String message) : super(message, statusCode: 409, code: 'CONFLICT');
}
