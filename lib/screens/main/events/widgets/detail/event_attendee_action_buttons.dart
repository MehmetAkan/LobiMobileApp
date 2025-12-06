import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'event_detail_action_button.dart';
import 'event_attendee_action_dropdown.dart';

class EventAttendeeActionButtons extends StatelessWidget {
  final VoidCallback onTicket;
  final VoidCallback? onContact; // Optional - Phase 2 feature
  final VoidCallback onCancelAttendance;

  const EventAttendeeActionButtons({
    super.key,
    required this.onTicket,
    this.onContact, // No longer required
    required this.onCancelAttendance,
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

        // Conditionally show contact button (Phase 2)
        if (onContact != null) ...[
          Expanded(
            child: EventDetailActionButton(
              icon: LucideIcons.messageCircle400,
              label: 'İletişim',
              onTap: onContact!,
            ),
          ),
          SizedBox(width: 10.w),
        ],

        // Daha Fazla - Dropdown
        Expanded(
          child: EventAttendeeActionDropdown(
            onCancelAttendance: onCancelAttendance,
          ),
        ),
      ],
    );
  }
}
