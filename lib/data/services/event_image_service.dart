import 'package:lobi_application/core/constants/app_constants.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/errors/error_handler.dart';
import 'package:lobi_application/data/models/event_image_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// EventImageService - event_images tablosu ile iletişim
/// 
/// Sorumluluklar:
/// - Supabase'den resim verilerini getirme
/// - Kategori ve tag bazlı filtreleme
/// - Featured resimleri getirme
class EventImageService {
  SupabaseClient get _supabase => SupabaseManager.instance.client;

  /// Tüm resimleri getir
  /// @throws DatabaseException
  Future<List<EventImageModel>> getAllImages() async {
    try {
      AppLogger.debug('Tüm resimler getiriliyor...');

      final response = await _supabase
          .from(AppConstants.eventImagesTable)
          .select()
          .order('created_at', ascending: false);

      final images = (response as List)
          .map((json) => EventImageModel.fromJson(json))
          .toList();

      AppLogger.info('✅ ${images.length} resim getirildi');
      return images;
    } catch (e, stackTrace) {
      AppLogger.error('Resimler getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Kategoriye göre resimleri getir
  /// @throws DatabaseException
  Future<List<EventImageModel>> getImagesByCategory(String categoryId) async {
    try {
      AppLogger.debug('Kategori resimleri getiriliyor: $categoryId');

      final response = await _supabase
          .from(AppConstants.eventImagesTable)
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      final images = (response as List)
          .map((json) => EventImageModel.fromJson(json))
          .toList();

      AppLogger.info('✅ ${images.length} resim getirildi (kategori: $categoryId)');
      return images;
    } catch (e, stackTrace) {
      AppLogger.error('Kategori resimleri getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Featured (önerilen) resimleri getir
  /// @throws DatabaseException
  Future<List<EventImageModel>> getFeaturedImages() async {
    try {
      AppLogger.debug('Featured resimler getiriliyor...');

      final response = await _supabase
          .from(AppConstants.eventImagesTable)
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false);

      final images = (response as List)
          .map((json) => EventImageModel.fromJson(json))
          .toList();

      AppLogger.info('✅ ${images.length} featured resim getirildi');
      return images;
    } catch (e, stackTrace) {
      AppLogger.error('Featured resimler getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Tag ile arama yap
  /// 
  /// PostgreSQL'de array içinde arama için @> operatörü kullanıyoruz
  /// Örnek: tags @> ARRAY['açık hava']
  /// 
  /// @throws DatabaseException
  Future<List<EventImageModel>> searchImagesByTags(List<String> tags) async {
    try {
      if (tags.isEmpty) {
        return getAllImages();
      }

      AppLogger.debug('Tag ile arama yapılıyor: $tags');

      // PostgreSQL array overlap operatörü: tags && ARRAY['tag1', 'tag2']
      // Yani tags array'inde herhangi bir tag eşleşirse döner
      final response = await _supabase
          .from(AppConstants.eventImagesTable)
          .select()
          .overlaps('tags', tags)
          .order('created_at', ascending: false);

      final images = (response as List)
          .map((json) => EventImageModel.fromJson(json))
          .toList();

      AppLogger.info('✅ ${images.length} resim bulundu (tags: $tags)');
      return images;
    } catch (e, stackTrace) {
      AppLogger.error('Tag arama hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Kategoriye özel featured resimleri getir
  /// @throws DatabaseException
  Future<List<EventImageModel>> getFeaturedImagesByCategory(
    String categoryId,
  ) async {
    try {
      AppLogger.debug('Kategori featured resimleri getiriliyor: $categoryId');

      final response = await _supabase
          .from(AppConstants.eventImagesTable)
          .select()
          .eq('category_id', categoryId)
          .eq('is_featured', true)
          .order('created_at', ascending: false);

      final images = (response as List)
          .map((json) => EventImageModel.fromJson(json))
          .toList();

      AppLogger.info(
        '✅ ${images.length} featured resim getirildi (kategori: $categoryId)',
      );
      return images;
    } catch (e, stackTrace) {
      AppLogger.error('Kategori featured resimleri getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Tek bir resim getir (ID ile)
  /// @throws DatabaseException
  Future<EventImageModel?> getImageById(String imageId) async {
    try {
      AppLogger.debug('Resim getiriliyor: $imageId');

      final response = await _supabase
          .from(AppConstants.eventImagesTable)
          .select()
          .eq('id', imageId)
          .maybeSingle();

      if (response == null) {
        AppLogger.debug('Resim bulunamadı: $imageId');
        return null;
      }

      final image = EventImageModel.fromJson(response);
      AppLogger.debug('✅ Resim getirildi: ${image.url}');
      return image;
    } catch (e, stackTrace) {
      AppLogger.error('Resim getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }
}