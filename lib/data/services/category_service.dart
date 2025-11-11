import 'package:lobi_application/core/constants/app_constants.dart';
import 'package:lobi_application/core/supabase_client.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/errors/error_handler.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CategoryService - event_categories tablosu ile iletişim
/// 
/// Sorumluluklar:
/// - Kategorileri Supabase'den getirme
/// - Aktif kategorileri filtreleme
/// - Display order'a göre sıralama
class CategoryService {
  SupabaseClient get _supabase => SupabaseManager.instance.client;

  /// Tüm aktif kategorileri getir (display_order'a göre sıralı)
  /// @throws DatabaseException
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      AppLogger.debug('Kategoriler getiriliyor...');

      final response = await _supabase
          .from(AppConstants.eventCategoriesTable)
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      AppLogger.info('✅ ${categories.length} kategori getirildi');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.error('Kategoriler getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// Tek bir kategori getir (ID ile)
  /// @throws DatabaseException
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      AppLogger.debug('Kategori getiriliyor: $categoryId');

      final response = await _supabase
          .from(AppConstants.eventCategoriesTable)
          .select()
          .eq('id', categoryId)
          .maybeSingle();

      if (response == null) {
        AppLogger.debug('Kategori bulunamadı: $categoryId');
        return null;
      }

      final category = CategoryModel.fromJson(response);
      AppLogger.debug('✅ Kategori getirildi: ${category.name}');
      return category;
    } catch (e, stackTrace) {
      AppLogger.error('Kategori getirme hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }

  /// İsme göre kategori ara
  /// @throws DatabaseException
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      if (query.isEmpty) {
        return getAllCategories();
      }

      AppLogger.debug('Kategori arama: $query');

      final response = await _supabase
          .from(AppConstants.eventCategoriesTable)
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('display_order', ascending: true);

      final categories = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      AppLogger.info('✅ ${categories.length} kategori bulundu');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.error('Kategori arama hatası', e, stackTrace);
      throw ErrorHandler.handle(e);
    }
  }
}