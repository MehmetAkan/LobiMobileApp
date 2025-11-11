import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/event_image_model.dart';
import 'package:lobi_application/data/repositories/event_image_repository.dart';

/// EventImageRepository Provider
final eventImageRepositoryProvider = Provider<EventImageRepository>((ref) {
  return getIt<EventImageRepository>();
});

/// Tüm resimleri getir
final allEventImagesProvider = FutureProvider<List<EventImageModel>>((ref) async {
  final repository = ref.watch(eventImageRepositoryProvider);
  return await repository.getAllImages();
});

/// Featured (önerilen) resimleri getir
final featuredEventImagesProvider = FutureProvider<List<EventImageModel>>((ref) async {
  final repository = ref.watch(eventImageRepositoryProvider);
  return await repository.getFeaturedImages();
});

/// Kategoriye göre resimleri getir
/// 
/// Kullanım:
/// ```dart
/// final images = ref.watch(eventImagesByCategoryProvider('category-id'));
/// ```
final eventImagesByCategoryProvider = FutureProvider.family<List<EventImageModel>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(eventImageRepositoryProvider);
    return await repository.getImagesByCategory(categoryId);
  },
);

/// Kategoriye göre featured resimleri getir
final featuredImagesByCategoryProvider = FutureProvider.family<List<EventImageModel>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(eventImageRepositoryProvider);
    return await repository.getFeaturedImagesByCategory(categoryId);
  },
);

/// Tag ile arama
/// 
/// Kullanım:
/// ```dart
/// final images = ref.watch(searchEventImagesByTagsProvider(['açık hava', 'gece']));
/// ```
final searchEventImagesByTagsProvider = FutureProvider.family<List<EventImageModel>, List<String>>(
  (ref, tags) async {
    final repository = ref.watch(eventImageRepositoryProvider);
    return await repository.searchImagesByTags(tags);
  },
);

/// Seçili resim state (modal'da kullanıcının seçtiği resim)
/// 
/// Kullanım:
/// ```dart
/// final selectedImage = ref.watch(selectedEventImageProvider);
/// ref.read(selectedEventImageProvider.notifier).state = image;
/// ```
final selectedEventImageProvider = StateProvider<EventImageModel?>((ref) => null);

/// EventImageController - Resim yönetimi için state notifier
/// 
/// Kullanım:
/// ```dart
/// final controller = ref.read(eventImageControllerProvider.notifier);
/// await controller.refreshImages();
/// await controller.searchByTags(['açık hava']);
/// ```
class EventImageController extends StateNotifier<AsyncValue<List<EventImageModel>>> {
  final EventImageRepository _repository;

  EventImageController(this._repository) : super(const AsyncValue.loading()) {
    // İlk yüklemede tüm resimleri getir
    loadAllImages();
  }

  /// Tüm resimleri yükle
  Future<void> loadAllImages({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();

    try {
      final images = await _repository.getAllImages(forceRefresh: forceRefresh);
      state = AsyncValue.data(images);
      AppLogger.info('✅ ${images.length} resim yüklendi');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('Resimler yüklenemedi', e, stackTrace);
    }
  }

  /// Kategoriye göre filtrele
  Future<void> loadImagesByCategory(String categoryId) async {
    state = const AsyncValue.loading();

    try {
      final images = await _repository.getImagesByCategory(categoryId);
      state = AsyncValue.data(images);
      AppLogger.info('✅ Kategori resimleri yüklendi: ${images.length}');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('Kategori resimleri yüklenemedi', e, stackTrace);
    }
  }

  /// Featured resimleri yükle
  Future<void> loadFeaturedImages() async {
    state = const AsyncValue.loading();

    try {
      final images = await _repository.getFeaturedImages();
      state = AsyncValue.data(images);
      AppLogger.info('✅ Featured resimler yüklendi: ${images.length}');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('Featured resimler yüklenemedi', e, stackTrace);
    }
  }

  /// Tag ile arama
  Future<void> searchByTags(List<String> tags) async {
    state = const AsyncValue.loading();

    try {
      final images = await _repository.searchImagesByTags(tags);
      state = AsyncValue.data(images);
      AppLogger.info('✅ Arama sonucu: ${images.length} resim');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      AppLogger.error('Arama başarısız', e, stackTrace);
    }
  }

  /// Cache'i temizle ve yeniden yükle
  Future<void> refreshImages() async {
    _repository.clearCache();
    await loadAllImages(forceRefresh: true);
  }

  /// Belirli kategori cache'ini temizle
  void clearCategoryCache(String categoryId) {
    _repository.clearCategoryCache(categoryId);
  }
}

/// EventImageController Provider
final eventImageControllerProvider = StateNotifierProvider<EventImageController, AsyncValue<List<EventImageModel>>>(
  (ref) {
    final repository = ref.watch(eventImageRepositoryProvider);
    return EventImageController(repository);
  },
);