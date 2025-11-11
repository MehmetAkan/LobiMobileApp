import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/services/category_service.dart';

/// CategoryRepository - Kategori business logic
///
/// Sorumluluklar:
/// - Service metodlarını koordine etme
/// - Cache yönetimi (kategoriler nadiren değişir)
/// - Error handling
class CategoryRepository {
  final CategoryService _service;

  // Cache (kategoriler genelde statik olduğu için)
  List<CategoryModel>? _cachedCategories;
  DateTime? _lastFetchTime;

  CategoryRepository(this._service);

  /// Tüm kategorileri getir (cache ile)
  Future<List<CategoryModel>> getAllCategories({bool forceRefresh = false}) async {
    try {
      // Cache kontrolü (30 dakika)
      if (!forceRefresh &&
          _cachedCategories != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!).inMinutes < 30) {
        AppLogger.debug('Kategoriler cache\'den getiriliyor');
        return _cachedCategories!;
      }

      AppLogger.info('📂 Kategoriler Supabase\'den getiriliyor...');
      final categories = await _service.getAllCategories();

      // Cache'e kaydet
      _cachedCategories = categories;
      _lastFetchTime = DateTime.now();

      return categories;
    } on AppException catch (e) {
      AppLogger.error('Kategoriler getirilemedi', e);
      
      // Eğer cache varsa onu dön (graceful degradation)
      if (_cachedCategories != null) {
        AppLogger.warning('⚠️ Hata nedeniyle cache\'den dönülüyor');
        return _cachedCategories!;
      }
      
      // Cache de yoksa mock data dön (son çare)
      AppLogger.warning('⚠️ Cache yok, mock data dönülüyor');
      return CategoryModel.getMockCategories();
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      
      // Cache varsa onu dön
      if (_cachedCategories != null) {
        return _cachedCategories!;
      }
      
      // Son çare: mock data
      return CategoryModel.getMockCategories();
    }
  }

  /// Tek bir kategori getir
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      // Önce cache'de ara
      if (_cachedCategories != null) {
        try {
          return _cachedCategories!.firstWhere((cat) => cat.id == categoryId);
        } catch (_) {
          // Cache'de bulunamadı, servisten getir
        }
      }

      AppLogger.info('📂 Kategori getiriliyor: $categoryId');
      return await _service.getCategoryById(categoryId);
    } on AppException catch (e) {
      AppLogger.error('Kategori getirilemedi', e);
      
      // Mock kategorilerde ara (fallback)
      try {
        return CategoryModel.getMockCategories().firstWhere((cat) => cat.id == categoryId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      return null;
    }
  }

  /// İsme göre kategori ara
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllCategories();
      }

      // Önce cache'de ara
      if (_cachedCategories != null) {
        final filtered = _cachedCategories!
            .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
        
        if (filtered.isNotEmpty) {
          AppLogger.debug('Kategori arama cache\'den: ${filtered.length} sonuç');
          return filtered;
        }
      }

      AppLogger.info('🔍 Kategori arama: $query');
      return await _service.searchCategories(query);
    } on AppException catch (e) {
      AppLogger.error('Kategori arama hatası', e);
      
      // Cache'de ara (fallback)
      if (_cachedCategories != null) {
        return _cachedCategories!
            .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      
      return [];
    } catch (e) {
      AppLogger.error('Beklenmeyen hata', e);
      return [];
    }
  }

  /// Cache'i temizle
  void clearCache() {
    _cachedCategories = null;
    _lastFetchTime = null;
    AppLogger.debug('🧹 Category cache temizlendi');
  }

  /// Cache'i yenile
  Future<void> refreshCache() async {
    clearCache();
    await getAllCategories(forceRefresh: true);
  }
}