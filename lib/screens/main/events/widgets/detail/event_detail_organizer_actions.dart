import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class EventDetailOrganizerActions extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onAnnouncement;
  final VoidCallback onManage;

  const EventDetailOrganizerActions({
    super.key,
    required this.onShare,
    required this.onAnnouncement,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Paylaş butonu
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.share2400,
            label: 'Paylaş',
            onTap: onShare,
          ),
        ),
        SizedBox(width: 10.w),
        
        // Duyuru butonu
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.megaphone400,
            label: 'Duyuru',
            onTap: onAnnouncement,
          ),
        ),
        SizedBox(width: 10.w),
        
        // Yönet butonu
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.settings400,
            label: 'Yönet',
            onTap: onManage,
          ),
        ),
      ],
    );
  }
}


class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: AppTheme.getAppBarButtonBg(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.getAppBarButtonBorder(context),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: AppTheme.white,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}