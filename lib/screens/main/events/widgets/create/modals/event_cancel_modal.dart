import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_modal_sheet.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// EventCancelModal - Etkinlik iptal modal'ı
///
/// Kullanım:
/// ```dart
/// final confirmed = await EventCancelModal.show(context: context);
/// if (confirmed == true) {
///   // İptal işlemi yap
/// }
/// ```
class EventCancelModal {
  static Future<bool?> show({required BuildContext context}) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _CancelContent(),
    );
  }
}

class _CancelContent extends StatelessWidget {
  const _CancelContent();

  @override
  Widget build(BuildContext context) {
    return EventModalSheet(
      icon: LucideIcons.badgeAlert400,
      title: 'Katılımı İptal Et',
      description:
          'Bu etkinliğe katılımınızı iptal etmek istediğinizden emin misiniz? Organizatör bilgilendirilecektir.',
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Row(
            children: [
              // Onayla butonu (Kırmızı)
              Expanded(
                child: _buildButton(
                  context: context,
                  label: 'Katılımı İptal Et',
                  onTap: () => Navigator.of(context).pop(true),
                  isPrimary: true,
                  isDanger: true,
                ),
              ),
              SizedBox(width: 10.w),
              // Kapat butonu
              Expanded(
                child: _buildButton(
                  context: context,
                  label: 'Vazgeç',
                  onTap: () => Navigator.of(context).pop(false),
                  isPrimary: false,
                  isDanger: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required bool isDanger,
  }) {
    final Color bgColor;
    final Color textColor;

    if (isDanger) {
      // Kırmızı buton
      bgColor = AppTheme.red700;
      textColor = AppTheme.white;
    } else if (isPrimary) {
      // Normal primary buton
      bgColor = AppTheme.white;
      textColor = AppTheme.black800;
    } else {
      // Secondary buton
      bgColor = AppTheme.getAppBarButtonBg(context).withOpacity(0.3);
      textColor = AppTheme.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25.r),
          border: isPrimary
              ? null
              : Border.all(color: AppTheme.white.withOpacity(0.2), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
