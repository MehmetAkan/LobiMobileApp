import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'event_detail_action_button.dart';

class EventDetailOrganizerActions extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onAnnouncement;
  final VoidCallback? onRequests; // Optional now
  final VoidCallback onManage;
  final bool showRequests; // Control visibility

  const EventDetailOrganizerActions({
    super.key,
    required this.onShare,
    required this.onAnnouncement,
    this.onRequests,
    required this.onManage,
    this.showRequests = true, // Default true for backwards compatibility
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Conditionally show requests button
        if (showRequests && onRequests != null) ...[
          Expanded(
            child: EventDetailActionButton(
              icon: LucideIcons.listTodo400,
              label: 'İstekler',
              onTap: onRequests!,
              type: ActionButtonType.featured,
            ),
          ),
          SizedBox(width: 5.w),
        ],
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
