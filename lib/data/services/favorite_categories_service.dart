import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lobi_application/core/utils/logger.dart';

/// Service for managing user favorite categories
class FavoriteCategoriesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Save user's favorite categories
  /// Replaces existing favorites with new selection
  Future<void> saveFavoriteCategories({
    required String userId,
    required List<String> categoryIds,
  }) async {
    try {
      // 1. Delete existing favorites
      await _supabase
          .from('user_favorite_categories')
          .delete()
          .eq('user_id', userId);

      // 2. Insert new favorites
      final data = categoryIds
          .map((categoryId) => {'user_id': userId, 'category_id': categoryId})
          .toList();

      await _supabase.from('user_favorite_categories').insert(data);

      AppLogger.success('Favorite categories saved: ${categoryIds.length}');
    } catch (e, stackTrace) {
      AppLogger.error('Save favorite categories error', e, stackTrace);
      rethrow;
    }
  }

  /// Get user's favorite category IDs
  Future<List<String>> getFavoriteCategoryIds(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorite_categories')
          .select('category_id')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['category_id'] as String)
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Get favorite categories error', e, stackTrace);
      return [];
    }
  }

  /// Check if user has selected favorite categories
  Future<bool> hasFavoriteCategories(String userId) async {
    try {
      final count = await getFavoriteCategoryIds(userId);
      return count.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Add single favorite category
  Future<void> addFavoriteCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      await _supabase.from('user_favorite_categories').insert({
        'user_id': userId,
        'category_id': categoryId,
      });

      AppLogger.success('Category added to favorites: $categoryId');
    } catch (e, stackTrace) {
      AppLogger.error('Add favorite category error', e, stackTrace);
      rethrow;
    }
  }

  /// Remove single favorite category
  Future<void> removeFavoriteCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      await _supabase
          .from('user_favorite_categories')
          .delete()
          .eq('user_id', userId)
          .eq('category_id', categoryId);

      AppLogger.success('Category removed from favorites: $categoryId');
    } catch (e, stackTrace) {
      AppLogger.error('Remove favorite category error', e, stackTrace);
      rethrow;
    }
  }

  /// Check if category is favorite
  Future<bool> isFavoriteCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      final result = await _supabase
          .from('user_favorite_categories')
          .select()
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .maybeSingle();

      return result != null;
    } catch (e, stackTrace) {
      AppLogger.error('Check favorite category error', e, stackTrace);
      return false;
    }
  }
}
