import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/event_image_model.dart';
import 'package:lobi_application/data/services/event_image_service.dart';

/// EventImageRepository - Resim kütüphanesi business logic
///
/// Sorumluluklar:
/// - Service metodlarını koordine etme
/// - Business logic ve validation
/// - Error handling ve kullanıcı dostu mesajlar
/// - Caching (ileride eklenebilir)
class EventImageRepository {
  final EventImageService _service;

  // Cache (opsiyonel - performans için)
  List<EventImageModel>? _cachedImages;
  Map<String, List<EventImageModel>> _categoryCache = {};
  DateTime? _lastFetchTime;

  EventImageRepository(this._service);

  /// Tüm resimleri getir (cache ile)
  Future<List<EventImageModel>> getAllImages({bool forceRefresh = false}) async {
    try {
      // Cache kontrolü (5 dakikadan eski değilse cache'den dön)
      if (!forceRefresh &&
          _cachedImages != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
        AppLogger.debug('Resimler cache\'den getiriliyor');
        return _cachedImages!;
      }

      AppLogger.info('📸 Tüm resimler getiriliyor...');
      final images = await _service.getAllImages();

      // Cache'e kaydet
      _cachedImages = images;
      _lastFetchTime = DateTime.now();

      return images;
    } on AppException catch (e) {
      AppLogger.error('Resimler getirilemedi', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      throw UnknownException(
        'Resimler yüklenirken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Kategoriye göre resimleri getir (cache ile)
  Future<List<EventImageModel>> getImagesByCategory(
    String categoryId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Validation
      if (categoryId.isEmpty) {
        throw ValidationException('Kategori ID boş olamaz');
      }

      // Cache kontrolü
      if (!forceRefresh && _categoryCache.containsKey(categoryId)) {
        AppLogger.debug('Kategori resimleri cache\'den getiriliyor');
        return _categoryCache[categoryId]!;
      }

      AppLogger.info('📸 Kategori resimleri getiriliyor: $categoryId');
      final images = await _service.getImagesByCategory(categoryId);

      // Cache'e kaydet
      _categoryCache[categoryId] = images;

      return images;
    } on AppException catch (e) {
      AppLogger.error('Kategori resimleri getirilemedi', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      throw UnknownException(
        'Kategori resimleri yüklenirken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Önerilen (featured) resimleri getir
  Future<List<EventImageModel>> getFeaturedImages() async {
    try {
      AppLogger.info('⭐ Featured resimler getiriliyor...');
      return await _service.getFeaturedImages();
    } on AppException catch (e) {
      AppLogger.error('Featured resimler getirilemedi', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      throw UnknownException(
        'Önerilen resimler yüklenirken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Tag ile arama yap
  /// 
  /// Business logic: 
  /// - Boş tag listesi kontrolü
  /// - Tag'leri lowercase'e çevir
  /// - Gereksiz boşlukları temizle
  Future<List<EventImageModel>> searchImagesByTags(List<String> tags) async {
    try {
      // Validation ve normalization
      if (tags.isEmpty) {
        AppLogger.debug('Tag listesi boş, tüm resimler getiriliyor');
        return await getAllImages();
      }

      // Tag'leri normalize et (lowercase, trim)
      final normalizedTags = tags
          .map((tag) => tag.trim().toLowerCase())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (normalizedTags.isEmpty) {
        return await getAllImages();
      }

      AppLogger.info('🔍 Tag ile arama: $normalizedTags');
      return await _service.searchImagesByTags(normalizedTags);
    } on AppException catch (e) {
      AppLogger.error('Tag arama hatası', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      throw UnknownException(
        'Arama sırasında bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Kategoriye özel featured resimleri getir
  Future<List<EventImageModel>> getFeaturedImagesByCategory(
    String categoryId,
  ) async {
    try {
      if (categoryId.isEmpty) {
        throw ValidationException('Kategori ID boş olamaz');
      }

      AppLogger.info('⭐ Kategori featured resimleri: $categoryId');
      return await _service.getFeaturedImagesByCategory(categoryId);
    } on AppException catch (e) {
      AppLogger.error('Kategori featured resimleri getirilemedi', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      throw UnknownException(
        'Kategori önerilen resimleri yüklenirken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Tek bir resim getir
  Future<EventImageModel?> getImageById(String imageId) async {
    try {
      if (imageId.isEmpty) {
        throw ValidationException('Resim ID boş olamaz');
      }

      // Önce cache'de ara
      if (_cachedImages != null) {
        final cachedImage = _cachedImages!.firstWhere(
          (img) => img.id == imageId,
          orElse: () => throw StateError('Not found'),
        );
        return cachedImage;
      }

      AppLogger.info('📸 Resim getiriliyor: $imageId');
      return await _service.getImageById(imageId);
    } on StateError {
      // Cache'de bulunamadı, servisten getir
      return await _service.getImageById(imageId);
    } on AppException catch (e) {
      AppLogger.error('Resim getirilemedi', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      throw UnknownException(
        'Resim yüklenirken bir hata oluştu',
        originalError: e,
      );
    }
  }

  /// Cache'i temizle
  void clearCache() {
    _cachedImages = null;
    _categoryCache.clear();
    _lastFetchTime = null;
    AppLogger.debug('🧹 Image cache temizlendi');
  }

  /// Belirli kategori cache'ini temizle
  void clearCategoryCache(String categoryId) {
    _categoryCache.remove(categoryId);
    AppLogger.debug('🧹 Kategori cache temizlendi: $categoryId');
  }
}