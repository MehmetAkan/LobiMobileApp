import 'package:lobi_application/core/utils/logger.dart';

/// Retry network operations with exponential backoff
Future<T> withNetworkRetry<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int attempts = 0;

  while (attempts < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      attempts++;

      // Check if network error
      if (isNetworkError(e) && attempts < maxAttempts) {
        // Exponential backoff: 1s, 2s, 4s
        final delay = initialDelay * (1 << (attempts - 1));
        AppLogger.debug(
          'Retrying after ${delay.inSeconds}s (attempt $attempts)',
        );
        await Future.delayed(delay);
        continue;
      }

      // Not a network error or max attempts reached
      rethrow;
    }
  }

  throw Exception('Max retry attempts ($maxAttempts) reached');
}

/// Check if error is network-related
bool isNetworkError(dynamic error) {
  if (error == null) return false;

  final errorString = error.toString().toLowerCase();
  return errorString.contains('network') ||
      errorString.contains('connection') ||
      errorString.contains('timeout') ||
      errorString.contains('unreachable') ||
      errorString.contains('socketexception');
}

/// Get user-friendly error message
String getNetworkErrorMessage(dynamic error) {
  if (isNetworkError(error)) {
    return 'İnternet bağlantınızı kontrol edin';
  }

  // Generic error
  return 'Bir hata oluştu. Lütfen tekrar deneyin.';
}
