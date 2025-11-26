import 'dart:math';

/// Service for generating and validating verification tokens
///
/// Format: ABC-123-XYZ (3-3-3 alphanumeric, dash separated)
///
/// Example:
/// ```dart
/// final token = VerificationTokenService.generate();
/// print(token); // "A7B-3C9-X1Z"
///
/// final isValid = VerificationTokenService.isValid(token);
/// ```
class VerificationTokenService {
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final _random = Random.secure();

  /// Generate a new verification token
  ///
  /// Returns: String in format "ABC-123-XYZ"
  static String generate() {
    String part1 = _generatePart(3);
    String part2 = _generatePart(3);
    String part3 = _generatePart(3);
    return '$part1-$part2-$part3';
  }

  /// Generate a single part of the token
  static String _generatePart(int length) {
    return List.generate(
      length,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }

  /// Validate token format
  ///
  /// Returns: true if token matches ABC-123-XYZ pattern
  static bool isValid(String token) {
    final regex = RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}-[A-Z0-9]{3}$');
    return regex.hasMatch(token);
  }
}
