import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Notification Permission Context
enum NotificationPermissionContext {
  eventApproved, // İlk etkinlik onaylandı
  favoriteCategories, // Favori kategoriler seçildi
  general, // Genel durum
}

/// Notification Permission Modal
class NotificationPermissionModal {
  static void show(
    BuildContext context, {
    required NotificationPermissionContext permissionContext,
    required VoidCallback onAllow,
    VoidCallback? onDeny,
  }) {
    final config = _getConfig(permissionContext);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => CustomModalSheet(
        headerLeft: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Circle
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: config.iconBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: config.iconBorderColor, width: 1.5.w),
              ),
              child: Icon(config.icon, size: 22.sp, color: config.iconColor),
            ),
            SizedBox(height: 20.h),
            // Title
            Text(
              config.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextHeadColor(context),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8.h),
            // Description
            Text(
              config.description,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.zinc600,
                height: 1.4,
              ),
            ),
          ],
        ),
        showDivider: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Benefits List
            ...config.benefits.map((benefit) => _buildBenefitItem(benefit)),

            SizedBox(height: 20.h),

            // Action Buttons
            Row(
              children: [
                // Deny Button
                Expanded(
                  child: _buildSecondaryButton(
                    context,
                    label: 'Şimdi Değil',
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      onDeny?.call();
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                // Allow Button
                Expanded(
                  flex: 2,
                  child: _buildPrimaryButton(
                    context,
                    label: config.allowButtonText,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      onAllow();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get configuration based on context
  static _ModalConfig _getConfig(NotificationPermissionContext context) {
    switch (context) {
      case NotificationPermissionContext.eventApproved:
        return _ModalConfig(
          icon: LucideIcons.bell,
          iconColor: AppTheme.black800,
          iconBackgroundColor: AppTheme.zinc200,
          iconBorderColor: AppTheme.zinc300,
          title: 'Etkinlik Güncellemeleri',
          description:
              'Katıldığın etkinlikler için önemli bildirimleri kaçırma!',
          benefits: [
            'Etkinlik 1 saat kala hatırlatma',
            'Etkinlik iptal/güncelleme bildirimleri',
            'Organizatörden yeni duyurular',
          ],
          allowButtonText: 'Bildirimleri Aç',
        );

      case NotificationPermissionContext.favoriteCategories:
        return _ModalConfig(
          icon: LucideIcons.star,
          iconColor: AppTheme.green500,
          iconBackgroundColor: AppTheme.green100,
          iconBorderColor: AppTheme.green200,
          title: 'Yeni Etkinlik Bildirimleri',
          description:
              'İlgilendiğin kategorilerde yeni etkinlikler olduğunda seni bilgilendirelim',
          benefits: [
            'Favori kategorilerinde yeni etkinlikler',
            'Yakınında düzenlenecek etkinlikler',
            'Son dakika fırsatları',
          ],
          allowButtonText: 'Bildirim Al',
        );

      case NotificationPermissionContext.general:
        return _ModalConfig(
          icon: LucideIcons.bellRing,
          iconColor: AppTheme.black800,
          iconBackgroundColor: AppTheme.zinc200,
          iconBorderColor: AppTheme.zinc300,
          title: 'Bildirimleri Aç',
          description: 'Önemli güncellemeleri ve yeni etkinlikleri kaçırma',
          benefits: [
            'Etkinlik hatırlatmaları',
            'Yeni etkinlik bildirimleri',
            'Önemli güncellemeler',
          ],
          allowButtonText: 'İzin Ver',
        );
    }
  }

  /// Build benefit item
  static Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.green600,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.check500,
              size: 15.sp,
              color: AppTheme.white,
            ),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.black800,
                letterSpacing: -0.20,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Primary button
  static Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.black800,
      borderRadius: BorderRadius.circular(25.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 5.w),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.white,
              letterSpacing: -0.20,
            ),
          ),
        ),
      ),
    );
  }

  /// Secondary button
  static Widget _buildSecondaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.zinc100,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              letterSpacing: -0.20,
              fontWeight: FontWeight.w500,
              color: AppTheme.zinc1000,
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal Configuration
class _ModalConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color iconBorderColor;
  final String title;
  final String description;
  final List<String> benefits;
  final String allowButtonText;

  _ModalConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.iconBorderColor,
    required this.title,
    required this.description,
    required this.benefits,
    required this.allowButtonText,
  });
}
