import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'event_detail_action_button.dart';

class EventDetailOrganizerActions extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onAnnouncement;
  final VoidCallback onRequests;
  final VoidCallback onManage;

  const EventDetailOrganizerActions({
    super.key,
    required this.onShare,
    required this.onAnnouncement,
    required this.onRequests,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EventDetailActionButton(
            icon: LucideIcons.listTodo400,
            label: 'İstekler',
            onTap: onRequests,
            type: ActionButtonType.featured,
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: EventDetailActionButton(
            icon: LucideIcons.share2400,
            label: 'Paylaş',
            onTap: onShare,
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: EventDetailActionButton(
            icon: LucideIcons.megaphone400,
            label: 'Duyuru',
            onTap: onAnnouncement,
          ),
        ),
        SizedBox(width: 5.w),

        Expanded(
          child: EventDetailActionButton(
            icon: LucideIcons.settings400,
            label: 'Yönet',
            onTap: onManage,
          ),
        ),
      ],
    );
  }
}
