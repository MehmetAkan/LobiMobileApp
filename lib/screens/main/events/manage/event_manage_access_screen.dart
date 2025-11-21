import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/event_access_settings_box.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/event_access_settings_item.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/modals/event_access_visibility_modal.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/modals/event_access_capacity_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventManageAccessScreen extends StatefulWidget {
  const EventManageAccessScreen({super.key});

  @override
  State<EventManageAccessScreen> createState() =>
      _EventManageAccessScreenState();
}

class _EventManageAccessScreenState extends State<EventManageAccessScreen> {
  // State variables
  bool _isApprovalRequired = false;
  EventAccessVisibility _visibility = EventAccessVisibility.public;
  int? _capacity;

  /// Görünürlük modal'ını aç
  Future<void> _openVisibilityModal() async {
    final result = await EventAccessVisibilityModal.show(
      context: context,
      currentValue: _visibility,
    );

    if (result != null) {
      setState(() {
        _visibility = result;
      });
    }
  }

  /// Kontenjan modal'ını aç
  Future<void> _openCapacityModal() async {
    final result = await EventAccessCapacityModal.show(
      context: context,
      currentValue: _capacity,
    );

    setState(() {
      _capacity = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Erişim',
      children: [
        // Bildirimler Bölümü
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 0.h),
          child: Text(
            'Bildirimler',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.zinc600,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        EventAccessSettingsBox(
          children: [
            EventAccessSettingsItem.switchType(
              icon: LucideIcons.lock400,
              label: 'Onay gerekli',
              value: _isApprovalRequired,
              showDivider: false,
              onChanged: (value) {
                setState(() => _isApprovalRequired = value);
              },
            ),
          ],
        ),

        SizedBox(height: 30.h),

        // Seçenekler Bölümü
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 0.h),
          child: Text(
            'Seçenekler',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.zinc600,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        EventAccessSettingsBox(
          children: [
            EventAccessSettingsItem.action(
              icon: LucideIcons.globe400,
              label: 'Görünürlük',
              placeholder: 'Herkese Açık',
              value: EventAccessVisibilityModal.getDisplayText(_visibility),
              onTap: _openVisibilityModal,
            ),
            EventAccessSettingsItem.action(
              icon: LucideIcons.users400,
              label: 'Kontenjan',
              placeholder: 'Sınırsız',
              value: _capacity != null
                  ? EventAccessCapacityModal.getDisplayText(_capacity)
                  : null,
              onTap: _openCapacityModal,
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }
}
