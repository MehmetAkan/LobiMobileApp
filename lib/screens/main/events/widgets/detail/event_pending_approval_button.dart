import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventPendingApprovalButton - Onay bekleyen katılımcılar için gösterilen buton
///
/// Kullanıcı onay gerektiren bir etkinliğe katıldığında ve
/// durumu "pending" olduğunda gösterilir.
/// Full width buton olarak gösterilir.
/// Tıklanınca parent'taki onCancelConfirmed callback'ini çağırır.
class EventPendingApprovalButton extends StatelessWidget {
  final VoidCallback onCancelConfirmed;

  const EventPendingApprovalButton({
    super.key,
    required this.onCancelConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCancelConfirmed,
      child: Container(
        height: 55.h,
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
            Icon(LucideIcons.clock400, size: 20.sp, color: AppTheme.white),
            SizedBox(width: 8.w),
            Text(
              'Onay Bekleniyor',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
