import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/theme/app_theme.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Galeriden resim seç ve kırp (1:1)
  ///
  /// @returns Kırpılmış resmin File objesi veya null
  Future<File?> pickAndCropImage() async {
    try {
      AppLogger.debug('📸 Galeriden resim seçiliyor...');

      // 1. Galeriden resim seç
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Kırparken kalite kaybı olmasın
      );

      if (image == null) {
        AppLogger.debug('Resim seçilmedi (kullanıcı iptal etti)');
        return null;
      }

      AppLogger.info('✅ Resim seçildi: ${image.name}');

      // 2. Resmi kırp (1:1 oran)
      final croppedFile = await _cropImage(image.path);

      if (croppedFile == null) {
        AppLogger.debug('Resim kırpılmadı (kullanıcı iptal etti)');
        return null;
      }

      final fileSize = await croppedFile.length();
      AppLogger.info('✅ Resim kırpıldı: ${_formatFileSize(fileSize)}');

      return croppedFile;
    } catch (e, stackTrace) {
      AppLogger.error('Galeri resim seçme/kırpma hatası', e, stackTrace);
      return null;
    }
  }

  /// Galeriden resim seç ve yuvarlak kırp (1:1 - Profil fotoğrafı için)
  ///
  /// @returns Kırpılmış resmin File objesi veya null
  Future<File?> pickAndCropCircularImage() async {
    try {
      AppLogger.debug('📸 Galeriden profil resmi seçiliyor...');

      // 1. Galeriden resim seç
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) {
        AppLogger.debug('Resim seçilmedi (kullanıcı iptal etti)');
        return null;
      }

      AppLogger.info('✅ Resim seçildi: ${image.name}');

      // 2. Resmi yuvarlak kırp (1:1 oran)
      final croppedFile = await _cropCircularImage(image.path);

      if (croppedFile == null) {
        AppLogger.debug('Resim kırpılmadı (kullanıcı iptal etti)');
        return null;
      }

      final fileSize = await croppedFile.length();
      AppLogger.info('✅ Profil resmi kırpıldı: ${_formatFileSize(fileSize)}');

      return croppedFile;
    } catch (e, stackTrace) {
      AppLogger.error('Profil resmi seçme/kırpma hatası', e, stackTrace);
      return null;
    }
  }

  /// Kamera ile resim çek ve yuvarlak kırp (1:1 - Profil fotoğrafı için)
  ///
  /// @returns Kırpılmış resmin File objesi veya null
  Future<File?> takeAndCropCircularPhoto() async {
    try {
      AppLogger.debug('📸 Kamera ile profil resmi çekiliyor...');

      // 1. Kamera ile resim çek
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image == null) {
        AppLogger.debug('Resim çekilmedi (kullanıcı iptal etti)');
        return null;
      }

      AppLogger.info('✅ Resim çekildi: ${image.name}');

      // 2. Resmi yuvarlak kırp (1:1 oran)
      final croppedFile = await _cropCircularImage(image.path);

      if (croppedFile == null) {
        AppLogger.debug('Resim kırpılmadı (kullanıcı iptal etti)');
        return null;
      }

      final fileSize = await croppedFile.length();
      AppLogger.info('✅ Profil resmi kırpıldı: ${_formatFileSize(fileSize)}');

      return croppedFile;
    } catch (e, stackTrace) {
      AppLogger.error('Kamera resmi çekme/kırpma hatası', e, stackTrace);
      return null;
    }
  }

  /// Resmi kırp (1:1 aspect ratio)
  Future<File?> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        compressQuality: 85,
        maxWidth: 1920,
        maxHeight: 1440,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          // Android ayarları
          AndroidUiSettings(
            toolbarTitle: 'Resmi Kırp',
            toolbarColor: AppTheme.red900,
            toolbarWidgetColor: AppTheme.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true, // Oranı sabit tut
            hideBottomControls: false,
            showCropGrid: true,
          ),
          // iOS ayarları
          IOSUiSettings(
            title: 'Resmi Kırp',
            aspectRatioLockEnabled: true, // Oranı sabit tut
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) {
        return null;
      }

      return File(croppedFile.path);
    } catch (e, stackTrace) {
      AppLogger.error('Resim kırpma hatası', e, stackTrace);
      return null;
    }
  }

  /// Resmi yuvarlak kırp (1:1 aspect ratio - Profil fotoğrafı için)
  Future<File?> _cropCircularImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ), // 1:1 for circle
        compressQuality: 90,
        maxWidth: 512, // Profile photo size
        maxHeight: 512,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          // Android ayarları
          AndroidUiSettings(
            toolbarTitle: 'Profil Fotoğrafını Kırp',
            toolbarColor: AppTheme.red900,
            toolbarWidgetColor: AppTheme.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
            cropStyle: CropStyle.circle, // Circular crop
          ),
          // iOS ayarları
          IOSUiSettings(
            title: 'Profil Fotoğrafını Kırp',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) {
        return null;
      }

      return File(croppedFile.path);
    } catch (e, stackTrace) {
      AppLogger.error('Profil resmi kırpma hatası', e, stackTrace);
      return null;
    }
  }

  /// Dosya boyutunu formatla (KB, MB)
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
