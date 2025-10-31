abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class AuthenticationException extends AppException {
  AuthenticationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class NetworkException extends AppException {
  NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class ValidationException extends AppException {
  ValidationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class DatabaseException extends AppException {
  DatabaseException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class UnknownException extends AppException {
  UnknownException(
    super.message, {
    super.code,
    super.originalError,
  });
}