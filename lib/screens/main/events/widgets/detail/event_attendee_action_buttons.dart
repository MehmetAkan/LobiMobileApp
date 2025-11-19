import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventAttendeeActionButtons - Katılımcı aksiyon butonları
/// 
/// Katılım durumu badge'inden sonra gösterilir.
/// 3 buton: Biletim, İletişim, Daha Fazla
/// 
/// Kullanım:
/// ```dart
/// EventAttendeeActionButtons(
///   onTicket: () => print('Biletim'),
///   onContact: () => print('İletişim'),
///   onMore: () => print('Daha Fazla'),
/// )
/// ```
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
        // Biletim butonu
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.ticket400,
            label: 'Biletim',
            onTap: onTicket,
          ),
        ),
        SizedBox(width: 10.w),
        
        // İletişim butonu
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.messageCircle400,
            label: 'İletişim',
            onTap: onContact,
          ),
        ),
        SizedBox(width: 10.w),
        
        // Daha Fazla butonu
        Expanded(
          child: _ActionButton(
            icon: LucideIcons.ellipsis400,
            label: 'Daha Fazla',
            onTap: onMore,
          ),
        ),
      ],
    );
  }
}

/// _ActionButton - Katılımcı aksiyon butonu
/// 
/// Private widget, sadece bu dosyada kullanılır.
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
            color: AppTheme.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.white.withValues(alpha: 0.2),
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