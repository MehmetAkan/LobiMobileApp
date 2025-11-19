import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'event_detail_action_button.dart';

class EventAttendeeActionButtons extends StatelessWidget {
  final VoidCallback onTicket;
  final VoidCallback onContact;
  final VoidCallback onMore;

  const EventAttendeeActionButtons({
    super.key,
    required this.onTicket,
    required this.onContact,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EventDetailActionButton(
            icon: LucideIcons.tickets400,
            label: 'Biletim',
            onTap: onTicket,
            type: ActionButtonType.featured,
          ),
        ),
        SizedBox(width: 10.w),

        Expanded(
          child: EventDetailActionButton(
            icon: LucideIcons.messageCircle400,
            label: 'İletişim',
            onTap: onContact,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: EventDetailActionButton(
            icon: LucideIcons.ellipsis400,
            label: 'Daha Fazla',
            onTap: onMore,
          ),
        ),
      ],
    );
  }
}
