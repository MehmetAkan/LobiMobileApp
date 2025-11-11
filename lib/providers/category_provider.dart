import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/repositories/category_repository.dart';

/// CategoryRepository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return getIt<CategoryRepository>();
});

/// Tüm kategorileri getir
/// 
/// Kullanım:
/// ```dart
/// final categoriesAsync = ref.watch(allCategoriesProvider);
/// categoriesAsync.when(
///   data: (categories) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Hata: $error'),
/// );
/// ```
final allCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getAllCategories();
});

/// Tek bir kategori getir (ID ile)
/// 
/// Kullanım:
/// ```dart
/// final categoryAsync = ref.watch(categoryByIdProvider('category-id'));
/// ```
final categoryByIdProvider = FutureProvider.family<CategoryModel?, String>(
  (ref, categoryId) async {
    final repository = ref.watch(categoryRepositoryProvider);
    return await repository.getCategoryById(categoryId);
  },
);

/// Kategori arama
/// 
/// Kullanım:
/// ```dart
/// final searchResults = ref.watch(searchCategoriesProvider('spor'));
/// ```
final searchCategoriesProvider = FutureProvider.family<List<CategoryModel>, String>(
  (ref, query) async {
    final repository = ref.watch(categoryRepositoryProvider);
    return await repository.searchCategories(query);
  },
);