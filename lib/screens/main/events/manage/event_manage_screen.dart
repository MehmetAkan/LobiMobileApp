import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/models/extensions/event_time_state_extension.dart';
import 'package:lobi_application/data/services/event_service.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/widgets/common/menu/menu_group.dart';

import 'event_manage_access_screen.dart';
import 'event_manage_checkin_screen.dart';
import 'event_manage_details_screen.dart';
import 'event_manage_guests_screen.dart';
import '../widgets/manage/event_cancel_modal.dart';

class EventManageScreen extends StatelessWidget {
  final EventModel event;

  const EventManageScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Etkinliği Yönet',
      children: [
        // ========================================
        // Event Details Group
        // (Blocked when event ended)
        // ========================================
        _buildBlockableMenuGroup(
          context: context,
          isEnabled: event.canEditEventDetails,
          items: [
            MenuItem(
              iconPath: "assets/images/system/settings/setting-event-icon.svg",
              title: 'Etkinlik Detayları',
              description: 'Etkinlik bilgilerini düzenle',
              onTap: () async {
                if (!event.canEditEventDetails) return;

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

        // ========================================
        // Guest Management Group
        // (Always visible - accessible at all times)
        // ========================================
        MenuGroup(
          items: [
            // Guest List - Always accessible
            MenuItem(
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

            // Check-in - Always accessible
            MenuItem(
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
        _buildBlockableMenuGroup(
          context: context,
          isEnabled: event.canManageAccess,
          items: [
            MenuItem(
              iconPath: "assets/images/system/settings/setting-lock-icon.svg",
              title: 'Erişim',
              description: 'Gizlilik ve erişim ayarları',
              onTap: () {
                if (!event.canManageAccess) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventManageAccessScreen(event: event),
                  ),
                );
              },
            ),
            // Kayıt Soruları - Commented out for Phase 2
            // MenuItem(
            //   iconPath: "assets/images/system/settings/setting-question-icon.svg",
            //   title: 'Kayıt Soruları',
            //   description: 'Katılımcılara sorulacak sorular',
            //   onTap: () {
            //     if (!event.canManageAccess) return;
            //
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const EventManageQuestionsScreen(),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),

        SizedBox(height: 20.h),

        // ========================================
        // Danger Zone
        // (Blocked when event ended)
        // ========================================
        _buildBlockableMenuGroup(
          context: context,
          isEnabled: event.canCancelEvent,
          items: [
            MenuItem(
              iconPath: "assets/images/system/settings/setting-delete-icon.svg",
              title: 'Etkinliği İptal Et',
              description: 'Bu işlem geri alınamaz',
              isDestructive: true,
              onTap: () {
                if (!event.canCancelEvent) return;
                _handleCancelEvent(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a menu group with opacity and disabled state
  /// when event conditions are not met
  Widget _buildBlockableMenuGroup({
    required BuildContext context,
    required bool isEnabled,
    required List<MenuItem> items,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: AbsorbPointer(
        absorbing: !isEnabled,
        child: MenuGroup(items: items),
      ),
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
}
