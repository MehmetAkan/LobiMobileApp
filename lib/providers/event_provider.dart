import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/models/event_day_group.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/data/services/location_service.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_visibility_modal.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return getIt<EventRepository>();
});

final createEventControllerProvider =
    StateNotifierProvider<CreateEventController, AsyncValue<void>>((ref) {
      return CreateEventController(ref);
    });

class CreateEventController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CreateEventController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createEvent({
    required String title,
    required String? description,
    required String? coverPhotoUrl,
    required DateTime? startDate,
    required DateTime? endDate,
    required LocationModel? location,
    required CategoryModel? category,
    required EventVisibility visibility,
    required bool isApprovalRequired,
    required int? capacity,
  }) async {
    try {
      if (title.isEmpty) {
        throw Exception('Etkinlik başlığı boş olamaz.');
      }

      if (startDate == null || endDate == null) {
        throw Exception('Başlangıç ve bitiş tarihi seçilmelidir.');
      }

      if (location == null) {
        throw Exception('Konum seçilmelidir.');
      }

      if (category == null) {
        throw Exception('Kategori seçilmelidir.');
      }

      // Durumu 'yükleniyor' olarak ayarla
      state = const AsyncValue.loading();

      // Repository'yi provider'dan oku
      final repository = _ref.read(eventRepositoryProvider);

      // Repository'deki createEvent metodunu çağır
      await repository.createEvent(
        title: title,
        description: description,
        coverPhotoUrl: coverPhotoUrl,
        startDate: startDate,
        endDate: endDate,
        location: location,
        category: category,
        visibility: visibility,
        isApprovalRequired: isApprovalRequired,
        capacity: capacity,
      );

      // İşlem başarılı, durumu 'boşta'ya (data=null) geri döndür
      state = const AsyncValue.data(null);
      return true; // Başarılı
    } catch (e, st) {
      // Hata oluştu, durumu 'hata' olarak ayarla
      state = AsyncValue.error(e, st);
      return false; // Başarısız
    }
  }
}

class DiscoverEventsState {
  final List<EventModel> events;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  const DiscoverEventsState({
    required this.events,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
  });

  factory DiscoverEventsState.initial() {
    return const DiscoverEventsState(
      events: [],
      isLoadingInitial: false,
      isLoadingMore: false,
      hasMore: true,
      error: null,
    );
  }

  DiscoverEventsState copyWith({
    List<EventModel>? events,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return DiscoverEventsState(
      events: events ?? this.events,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DiscoverEventsController extends StateNotifier<DiscoverEventsState> {
  DiscoverEventsController(this._ref) : super(DiscoverEventsState.initial()) {
    loadInitial();
  }

  final Ref _ref;
  static const int _pageSize = 20;

  EventRepository get _repository => _ref.read(eventRepositoryProvider);

  /// İlk sayfayı yükler (ekran açıldığında).
  Future<void> loadInitial() async {
    if (state.isLoadingInitial) return;

    state = DiscoverEventsState.initial().copyWith(
      isLoadingInitial: true,
      clearError: true,
    );

    try {
      final events = await _repository.getUpcomingEventsPage(
        limit: _pageSize,
        offset: 0,
      );

      final hasMore = events.length == _pageSize;

      state = DiscoverEventsState(
        events: events,
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: hasMore,
        error: null,
      );
    } catch (e) {
      state = DiscoverEventsState(
        events: const [],
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: false,
        error: e,
      );
    }
  }

  /// Scroll altına indikçe çağrılacak, yeni sayfayı yükler.
  Future<void> loadMore() async {
    if (state.isLoadingInitial || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final nextEvents = await _repository.getUpcomingEventsPage(
        limit: _pageSize,
        offset: state.events.length,
      );

      final hasMore = nextEvents.length == _pageSize;

      state = state.copyWith(
        events: [...state.events, ...nextEvents],
        isLoadingMore: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }
}

final homeThisWeekEventsProvider = FutureProvider<List<EventDayGroup>>((
  ref,
) async {
  final repository = ref.read(eventRepositoryProvider);

  final events = await repository.getThisWeekEvents();

  final groups = groupEventsByDay(events);

  return groups;
});

final discoverEventsControllerProvider =
    StateNotifierProvider<DiscoverEventsController, DiscoverEventsState>(
  (ref) => DiscoverEventsController(ref),
);