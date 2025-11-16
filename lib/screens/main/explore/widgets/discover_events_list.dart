import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/lists/grouped_event_list.dart';

/// Keşfet ekranındaki dikey liste:
/// - Tüm yaklaşan etkinlikleri gösterir
/// - Tarihe göre gruplar (GroupedEventList kullanır)
/// - Scroll altına inildikçe yeni sayfa (loadMore) çeker
///
/// Büyük sistem mantığı:
/// - State Riverpod'dan gelir: [discoverEventsControllerProvider]
/// - Bu widget sadece UI + scroll dinleme işini yapar.
class DiscoverEventsList extends ConsumerStatefulWidget {
  /// Ana sayfadaki gibi, dışarıdan gelen scrollController.
  /// Genellikle sayfanın ana SingleChildScrollView'ı ile paylaşılıyor.
  final ScrollController scrollController;

  /// Navbar yüksekliği (DateHeader fade & active date için gerekiyor)
  final double navbarHeight;

  /// Aktif tarih değiştiğinde (scroll'a göre) dışarıya bildirir.
  /// CustomNavbar'da tarihi göstermek için kullanılabilir.
  final ValueChanged<DateTime?> onActiveDateChanged;

  const DiscoverEventsList({
    super.key,
    required this.scrollController,
    required this.navbarHeight,
    required this.onActiveDateChanged,
  });

  @override
  ConsumerState<DiscoverEventsList> createState() =>
      _DiscoverEventsListState();
}

class _DiscoverEventsListState extends ConsumerState<DiscoverEventsList> {
  @override
  void initState() {
    super.initState();
    // Sonsuz scroll için listener ekliyoruz
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(discoverEventsControllerProvider);

    if (!state.hasMore ||
        state.isLoadingInitial ||
        state.isLoadingMore) {
      return;
    }

    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // Alt kısma yaklaştıysak (ör: son 400px içinde)
    if (currentScroll >= maxScroll - 400) {
      ref
          .read(discoverEventsControllerProvider.notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverEventsControllerProvider);

    // İlk yükleme (initial) durumu
    if (state.isLoadingInitial && state.events.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Hata durumu
    if (state.error != null && state.events.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
        child: Text(
          'Etkinlikler yüklenirken bir sorun oluştu.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.getTextDescColor(context),
          ),
        ),
      );
    }

    // Event'leri GroupedEventList'in beklediği flat Map yapısına çevir
    final items = <Map<String, dynamic>>[];

    for (final event in state.events) {
      final date = event.date;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      items.add({
        'id': event.id,
        'title': event.title,
        'imageUrl': event.imageUrl,
        // Gruplama için ISO tarih
        'date': date.toIso8601String(),
        // Kart üzerinde gösterilecek metin: saat
        'displayDate': '$hour:$minute',
        'location': event.location,
        'attendeeCount': event.attendeeCount,
        'isLiked': false,

        // 👇 Detay sayfası için ham model
        'eventModel': event,
      });
    }

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
        child: Text(
          'Şu anda gösterilecek etkinlik bulunmuyor.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.getTextDescColor(context),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupedEventList(
          events: items,
          scrollController: widget.scrollController,
          navbarHeight: widget.navbarHeight,
          onActiveDateChanged: widget.onActiveDateChanged,
        ),
        if (state.isLoadingMore)
          Padding(
            padding: EdgeInsets.only(
              top: 8.h,
              bottom: 16.h,
            ),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}
