import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/services/event_service.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/event_access_settings_box.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/event_access_settings_item.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/modals/event_access_visibility_modal.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/modals/event_access_capacity_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventManageAccessScreen extends StatefulWidget {
  final EventModel event;

  const EventManageAccessScreen({super.key, required this.event});

  @override
  State<EventManageAccessScreen> createState() =>
      _EventManageAccessScreenState();
}

class _EventManageAccessScreenState extends State<EventManageAccessScreen> {
  // State variables
  late bool _isApprovalRequired;
  late EventAccessVisibility _visibility;
  int? _capacity;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize from event
    _isApprovalRequired = widget.event.requiresApproval;
    _visibility = widget.event.isPublic
        ? EventAccessVisibility.public
        : EventAccessVisibility.private;
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  /// Görünürlük modal'ını aç
  Future<void> _openVisibilityModal() async {
    final result = await EventAccessVisibilityModal.show(
      context: context,
      currentValue: _visibility,
    );

    if (result != null && result != _visibility) {
      setState(() {
        _visibility = result;
        _markAsChanged();
      });
    }
  }

  /// Kontenjan modal'ını aç
  Future<void> _openCapacityModal() async {
    final result = await EventAccessCapacityModal.show(
      context: context,
      currentValue: _capacity,
    );

    setState(() {
      _capacity = result;
      _markAsChanged();
    });
  }

  /// Save changes to backend
  Future<void> _saveChanges() async {
    if (!_hasChanges || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final eventService = getIt<EventService>();

      // Update visibility
      final isPublic = _visibility == EventAccessVisibility.public;
      await eventService.updateEventVisibility(
        eventId: widget.event.id,
        isPublic: isPublic,
      );

      // Update approval requirement
      await eventService.updateEventApprovalRequirement(
        eventId: widget.event.id,
        requiresApproval: _isApprovalRequired,
      );

      if (mounted) {
        getIt<AppFeedbackService>().showSuccess('Erişim ayarları güncellendi');
        Navigator.pop(context, true); // Signal refresh
      }
    } catch (e) {
      if (mounted) {
        getIt<AppFeedbackService>().showError('Güncelleme başarısız: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Erişim',
      children: [
        // Bildirimler Bölümü
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 0.h),
          child: Text(
            'Bildirimler',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSettingsProfileSmallHead(context),
              height: 1.2,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        EventAccessSettingsBox(
          children: [
            EventAccessSettingsItem.switchType(
              icon: LucideIcons.lock400,
              label: 'Onay gerekli',
              value: _isApprovalRequired,
              showDivider: false,
              onChanged: (value) {
                setState(() {
                  _isApprovalRequired = value;
                  _markAsChanged();
                });
              },
            ),
          ],
        ),

        SizedBox(height: 30.h),

        // Seçenekler Bölümü
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 0.h),
          child: Text(
            'Seçenekler',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.getSettingsProfileSmallHead(context),
              height: 1.2,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        EventAccessSettingsBox(
          children: [
            EventAccessSettingsItem.action(
              icon: LucideIcons.globe400,
              label: 'Görünürlük',
              placeholder: 'Herkese Açık',
              value: EventAccessVisibilityModal.getDisplayText(_visibility),
              onTap: _openVisibilityModal,
            ),
            EventAccessSettingsItem.action(
              icon: LucideIcons.users400,
              label: 'Kontenjan',
              placeholder: 'Sınırsız',
              value: _capacity != null
                  ? EventAccessCapacityModal.getDisplayText(_capacity)
                  : null,
              onTap: _openCapacityModal,
              showDivider: false,
            ),
          ],
        ),

        SizedBox(height: 30.h),

        // Save Button
        if (_hasChanges)
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black800,
                disabledBackgroundColor: AppTheme.zinc700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Değişiklikleri Kaydet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
