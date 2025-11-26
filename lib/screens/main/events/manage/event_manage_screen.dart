import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/services/event_service.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'event_manage_access_screen.dart';
import 'event_manage_checkin_screen.dart';
import 'event_manage_details_screen.dart';
import 'event_manage_guests_screen.dart';
import 'event_manage_questions_screen.dart';
import '../widgets/manage/event_cancel_modal.dart';

class EventManageScreen extends StatelessWidget {
  final EventModel event;

  const EventManageScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Etkinliği Yönet',
      children: [
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              iconPath: "assets/images/system/settings/setting-event-icon.svg",
              title: 'Etkinlik Detayları',
              description: 'Etkinlik bilgilerini düzenle',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EventManageDetailsScreen(event: event),
                  ),
                );

                // If update successful, pop back to detail screen with refresh signal
                if (result == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              iconPath: "assets/images/system/settings/setting-user-icon.svg",
              title: 'Misafir Listesi',
              description: 'Katılımcıları görüntüle ve yönet',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventManageGuestsScreen(event: event),
                ),
              ),
            ),
            _MenuItem(
              iconPath: "assets/images/system/settings/setting-qr-icon.svg",
              title: 'Misafir Katılımı İşaretle',
              description: 'QR kod veya manuel giriş',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventManageCheckinScreen(event: event),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              iconPath: "assets/images/system/settings/setting-lock-icon.svg",
              title: 'Erişim',
              description: 'Gizlilik ve erişim ayarları',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventManageAccessScreen(event: event),
                ),
              ),
            ),
            _MenuItem(
              iconPath:
                  "assets/images/system/settings/setting-question-icon.svg",
              title: 'Kayıt Soruları',
              description: 'Katılımcılara sorulacak sorular',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManageQuestionsScreen(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              iconPath: "assets/images/system/settings/setting-delete-icon.svg",
              title: 'Etkinliği İptal Et',
              description: 'Bu işlem geri alınamaz',
              isDestructive: true,
              onTap: () => _handleCancelEvent(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleCancelEvent(BuildContext context) async {
    final confirmed = await EventCancelModal.show(context);

    if (confirmed == true && context.mounted) {
      try {
        await getIt<EventService>().cancelEvent(eventId: event.id);

        if (context.mounted) {
          getIt<AppFeedbackService>().showWarning('Etkinlik iptal edildi');
          // Pop all the way back to home
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (context.mounted) {
          getIt<AppFeedbackService>().showError('İptal işlemi başarısız: $e');
        }
      }
    }
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.zinc100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.zinc200),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _buildMenuItemWidget(context, item),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(left: 56.w),
                  child: Divider(height: 1, color: AppTheme.zinc400),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItemWidget(BuildContext context, _MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
          child: Row(
            children: [
              SvgPicture.asset(item.iconPath, width: 32.sp, height: 32.sp),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: item.isDestructive
                            ? AppTheme.red800
                            : AppTheme.black800,
                      ),
                    ),
                    if (item.description != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.zinc600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 20.sp,
                color: AppTheme.zinc600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String iconPath;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem({
    required this.iconPath,
    required this.title,
    this.description,
    required this.onTap,
    this.isDestructive = false,
  });
}
