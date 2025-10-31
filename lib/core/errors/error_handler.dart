import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is AuthException) {
      return AuthenticationException(
        _getLocalizedAuthError(error.message),
        code: error.statusCode,
        originalError: error,
      );
    }

    if (error is SocketException) {
      return NetworkException(
        'İnternet bağlantınızı kontrol edin',
        originalError: error,
      );
    }

    if (error is PostgrestException) {
      return DatabaseException(
        'Veritabanı hatası: ${error.message}',
        code: error.code,
        originalError: error,
      );
    }

    return UnknownException(
      'Beklenmeyen bir hata oluştu',
      originalError: error,
    );
  }

  static String _getLocalizedAuthError(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('invalid login')) {
      return 'Geçersiz giriş bilgileri';
    }
    if (lowerMessage.contains('email not confirmed')) {
      return 'E-posta adresi doğrulanmamış';
    }
    if (lowerMessage.contains('invalid otp')) {
      return 'Geçersiz doğrulama kodu';
    }
    if (lowerMessage.contains('user not found')) {
      return 'Kullanıcı bulunamadı';
    }
    if (lowerMessage.contains('network')) {
      return 'Bağlantı hatası';
    }
    
    return message;
  }
}