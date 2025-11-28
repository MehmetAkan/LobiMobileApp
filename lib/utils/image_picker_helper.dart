import 'dart:io';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/services/image_picker_service.dart';

/// ImagePickerResult - Resim seçme sonucu
class ImagePickerResult {
  final bool isSuccess;
  final File? imageFile;
  final String? errorMessage;

  const ImagePickerResult._({
    required this.isSuccess,
    this.imageFile,
    this.errorMessage,
  });

  factory ImagePickerResult.success(File imageFile) {
    return ImagePickerResult._(isSuccess: true, imageFile: imageFile);
  }

  factory ImagePickerResult.failure(String errorMessage) {
    return ImagePickerResult._(isSuccess: false, errorMessage: errorMessage);
  }

  factory ImagePickerResult.cancelled() {
    return ImagePickerResult._(isSuccess: false, errorMessage: null);
  }
}

/// ImagePickerHelper - Basitleştirilmiş resim seçme helper'ı
///
/// Sorumluluklar:
/// - Galeriden resim seç ve kırp
/// - Dosya validasyonu
/// - Kullanıcı dostu hata mesajları
class ImagePickerHelper {
  final ImagePickerService _service;

  // Maksimum dosya boyutu (10MB)
  static const int maxFileSizeInBytes = 10 * 1024 * 1024;

  ImagePickerHelper(this._service);

  /// Galeriden resim seç ve kırp
  Future<ImagePickerResult> pickAndCropImage() async {
    try {
      AppLogger.info('📸 Galeri açılıyor...');

      // Resim seç ve kırp
      final imageFile = await _service.pickAndCropImage();

      if (imageFile == null) {
        return ImagePickerResult.cancelled();
      }

      // Dosya validasyonu
      final validationResult = await _validateImage(imageFile);
      if (!validationResult.isSuccess) {
        return validationResult;
      }

      AppLogger.info('✅ Resim başarıyla seçildi ve kırpıldı');
      return ImagePickerResult.success(imageFile);
    } catch (e, stackTrace) {
      AppLogger.error('Resim seçme hatası', e, stackTrace);
      return ImagePickerResult.failure(
        'Resim seçilirken bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  /// Galeriden yuvarlak profil resmi seç ve kırp
  Future<ImagePickerResult> pickAndCropCircularImage() async {
    try {
      AppLogger.info('📸 Profil fotoğrafı seçiliyor...');

      // Resim seç ve yuvarlak kırp
      final imageFile = await _service.pickAndCropCircularImage();

      if (imageFile == null) {
        return ImagePickerResult.cancelled();
      }

      // Dosya validasyonu
      final validationResult = await _validateImage(imageFile);
      if (!validationResult.isSuccess) {
        return validationResult;
      }

      AppLogger.info('✅ Profil fotoğrafı başarıyla seçildi');
      return ImagePickerResult.success(imageFile);
    } catch (e, stackTrace) {
      AppLogger.error('Profil fotoğrafı seçme hatası', e, stackTrace);
      return ImagePickerResult.failure(
        'Profil fotoğrafı seçilirken bir hata oluştu.',
      );
    }
  }

  /// Resim dosyasını validate et
  Future<ImagePickerResult> _validateImage(File imageFile) async {
    try {
      // Dosya var mı kontrol et
      if (!await imageFile.exists()) {
        return ImagePickerResult.failure('Seçilen dosya bulunamadı');
      }

      // Dosya boyutunu kontrol et
      final fileSize = await imageFile.length();

      if (fileSize > maxFileSizeInBytes) {
        final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        return ImagePickerResult.failure(
          'Dosya çok büyük ($sizeInMB MB). Maksimum 10 MB olmalıdır.',
        );
      }

      AppLogger.debug(
        'Dosya validasyonu başarılı (${_formatFileSize(fileSize)})',
      );

      return ImagePickerResult.success(imageFile);
    } catch (e, stackTrace) {
      AppLogger.error('Dosya validasyon hatası', e, stackTrace);
      return ImagePickerResult.failure('Dosya doğrulanırken hata oluştu');
    }
  }

  /// Dosya boyutunu formatla
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
