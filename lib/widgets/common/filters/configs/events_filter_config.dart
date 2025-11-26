import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/widgets/common/filters/filter_option.dart';

/// Etkinlikler sayfası için filter seçenekleri
class EventsFilterConfig {
  static List<FilterOption> getOptions() {
    return [
      const FilterOption(
        id: 'all',
        label: 'Tüm Etkinlikler',
        icon: LucideIcons.galleryVerticalEnd400,
        isDefault: true,
      ),
      const FilterOption(
        id: 'organizer',
        label: 'Organizatör',
        icon: LucideIcons.shieldUser400,
      ),
      const FilterOption(
        id: 'attending',
        label: 'Katılacak',
        icon: LucideIcons.badgeCheck400,
      ),
      const FilterOption(
        id: 'pending',
        label: 'Beklemede',
        icon: LucideIcons.clockFading400,
      ),
      const FilterOption(
        id: 'rejected',
        label: 'Reddedildi',
        icon: LucideIcons.circleAlert400,
      ),
    ];
  }
}
