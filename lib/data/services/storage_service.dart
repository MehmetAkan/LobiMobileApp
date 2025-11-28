import 'dart:io';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Storage Service - Supabase Storage işlemleri
class StorageService {
  final _supabase = SupabaseManager.instance.client;

  static const String profilePhotosBucket = 'profile-photos';

  /// Upload profile photo to Supabase Storage
  ///
  /// @param userId User ID for folder structure
  /// @param imageFile Image file to upload
  /// @returns Public URL of uploaded image
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      AppLogger.debug('📤 Profil fotoğrafı yükleniyor: $userId');

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'avatar_$timestamp$extension';
      final filePath = '$userId/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(profilePhotosBucket)
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Replace if exists
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(profilePhotosBucket)
          .getPublicUrl(filePath);

      AppLogger.info('✅ Profil fotoğrafı yüklendi: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      AppLogger.error('Profil fotoğrafı yükleme hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Delete old profile photo
  ///
  /// @param avatarUrl Full URL of the photo to delete
  Future<void> deleteProfilePhoto(String avatarUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;

      // Find bucket name and file path
      final bucketIndex = pathSegments.indexOf('object');
      if (bucketIndex == -1 || bucketIndex + 2 >= pathSegments.length) {
        throw Exception('Invalid avatar URL format');
      }

      final filePath = pathSegments.sublist(bucketIndex + 2).join('/');

      AppLogger.debug('🗑️ Eski profil fotoğrafı siliniyor: $filePath');

      await _supabase.storage.from(profilePhotosBucket).remove([filePath]);

      AppLogger.info('✅ Eski profil fotoğrafı silindi');
    } catch (e, stackTrace) {
      AppLogger.error('Profil fotoğrafı silme hatası', e, stackTrace);
      // Don't rethrow - deletion is optional
    }
  }

  /// Delete all profile photos for a user
  Future<void> deleteAllUserPhotos(String userId) async {
    try {
      AppLogger.debug('🗑️ Kullanıcı fotoğrafları siliniyor: $userId');

      final files = await _supabase.storage
          .from(profilePhotosBucket)
          .list(path: userId);

      if (files.isEmpty) {
        AppLogger.debug('Silinecek fotoğraf yok');
        return;
      }

      final filePaths = files.map((file) => '$userId/${file.name}').toList();

      await _supabase.storage.from(profilePhotosBucket).remove(filePaths);

      AppLogger.info('✅ ${files.length} fotoğraf silindi');
    } catch (e, stackTrace) {
      AppLogger.error('Kullanıcı fotoğrafları silme hatası', e, stackTrace);
      rethrow;
    }
  }
}
