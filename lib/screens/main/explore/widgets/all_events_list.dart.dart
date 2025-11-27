import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/providers/event_provider.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';

class AllEventsList extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final double navbarHeight;
  final ValueChanged<DateTime?> onActiveDateChanged;
  final void Function(EventModel event)? onEventTap;

  const AllEventsList({
    super.key,
    required this.scrollController,
    required this.navbarHeight,
    required this.onActiveDateChanged,
    this.onEventTap,
  });

  @override
  ConsumerState<AllEventsList> createState() => _AllEventsListState();
}

class _AllEventsListState extends ConsumerState<AllEventsList> {
  final Map<int, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // 1. Pagination kontrolü
    _checkPagination();

    // 2. Aktif tarih kontrolü (navbar için)
    _updateActiveDate();
  }

  void _checkPagination() {
    final state = ref.read(discoverEventsControllerProvider);

    if (!state.hasMore || state.isLoadingInitial || state.isLoadingMore) {
      return;
    }

    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // Alt kısma yaklaştıysak (son 400px içinde)
    if (currentScroll >= maxScroll - 400) {
      ref.read(discoverEventsControllerProvider.notifier).loadMore();
    }
  }

  void _updateActiveDate() {
    if (!mounted) return;

    final state = ref.read(discoverEventsControllerProvider);
    if (state.events.isEmpty) return;

    DateTime? newActiveDate;

    // Her kartın pozisyonunu kontrol et
    for (int i = 0; i < state.events.length; i++) {
      final key = _cardKeys[i];
      if (key == null) continue;

      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final cardTop = position.dy;
        final cardBottom = cardTop + renderBox.size.height;

        // Navbar hizasındaki veya üstündeki ilk kartı bul
        if (cardTop <= widget.navbarHeight &&
            cardBottom > widget.navbarHeight) {
          newActiveDate = state.events[i].date.dateOnly;
          break;
        }
      }
    }

    widget.onActiveDateChanged(newActiveDate);
  }

  void _initializeKeys(int count) {
    for (int i = 0; i < count; i++) {
      if (!_cardKeys.containsKey(i)) {
        _cardKeys[i] = GlobalKey();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverEventsControllerProvider);

    // İlk yükleme
    if (state.isLoadingInitial && state.events.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Hata durumu
    if (state.error != null && state.events.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Text(
          'Etkinlikler yüklenirken bir sorun oluştu.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.getTextDescColor(context),
          ),
        ),
      );
    }

    // Boş durum
    if (state.events.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Text(
          'Şu anda gösterilecek etkinlik bulunmuyor.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.getTextDescColor(context),
          ),
        ),
      );
    }

    // Key'leri başlat
    _initializeKeys(state.events.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Düz liste (gruplama yok)
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: state.events.length,
          separatorBuilder: (context, index) {
            // Son kart için divider gösterme
            if (index == state.events.length - 1) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Divider(
                    color: AppTheme.zinc300,
                    thickness: 1,
                    height: 1,
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            );
          },
          itemBuilder: (context, index) {
            final event = state.events[index];

            // Tarih formatı: "Bugün - 14:44" veya "22 KAS PZT - 14:44"
            final dateText = event.date.toTodayTomorrowWithTime();

            return Container(
              key: _cardKeys[index],
              child: EventCardVertical(
                imageUrl: event.imageUrl,
                title: event.title,
                date: dateText,
                location: event.location,
                attendeeCount: event.attendeeCount,
                organizerName: event.organizerName,
                organizerUsername: event.organizerUsername,
                organizerPhotoUrl: event.organizerPhotoUrl,
                isLiked: false,
                showLikeButton: false,
                onTap: () => widget.onEventTap?.call(event),
              ),
            );
          },
        ),

        // Loading indicator (pagination)
        if (state.isLoadingMore)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
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
