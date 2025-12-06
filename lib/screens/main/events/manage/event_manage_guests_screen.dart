import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/models/guest_model.dart';
import 'package:lobi_application/data/models/event_attendance_status.dart';
import 'package:lobi_application/data/services/event_attendance_service.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/guest_list_item.dart';
import 'package:lobi_application/widgets/common/badges/status_badge.dart';
import 'package:lobi_application/widgets/common/inputs/custom_search_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/widgets/common/filters/filter_bottom_sheet.dart';
import 'package:lobi_application/widgets/common/filters/filter_option.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lobi_application/theme/app_theme.dart';

enum ModalButtonType { primary, secondary }

class EventManageGuestsScreen extends StatefulWidget {
  final EventModel event;

  const EventManageGuestsScreen({super.key, required this.event});

  @override
  State<EventManageGuestsScreen> createState() =>
      _EventManageGuestsScreenState();
}

class _EventManageGuestsScreenState extends State<EventManageGuestsScreen> {
  final EventAttendanceService _service = EventAttendanceService();
  List<GuestModel> _allGuests = [];
  List<GuestModel> _filteredGuests = [];
  bool _isLoading = true;

  FilterOption _selectedFilter = _filterOptions.first;

  static const List<FilterOption> _filterOptions = [
    FilterOption(
      id: 'all',
      label: 'Tümü',
      icon: LucideIcons.users400,
      isDefault: true,
    ),
    FilterOption(
      id: 'attending',
      label: 'Katılacaklar',
      icon: LucideIcons.clock400,
    ),
    FilterOption(
      id: 'attended',
      label: 'Katıldı',
      icon: LucideIcons.badgeCheck400,
    ),
    FilterOption(
      id: 'not_attending',
      label: 'Katılmadı',
      icon: LucideIcons.badgeX400,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() => _isLoading = true);

    try {
      final guestsData = await _service.getEventGuests(widget.event.id);
      final guests = guestsData
          .map((json) => GuestModel.fromJson(json))
          .toList();

      if (mounted) {
        setState(() {
          _allGuests = guests;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Guest load error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        getIt<AppFeedbackService>().showError('Misafir listesi yüklenemedi');
      }
    }
  }

  void _applyFilter() {
    if (_selectedFilter.id == 'all') {
      _filteredGuests = _allGuests;
    } else {
      _filteredGuests = _allGuests.where((guest) {
        switch (_selectedFilter.id) {
          case 'attending':
            return guest.status == EventAttendanceStatus.attending;
          case 'attended':
            return guest.status == EventAttendanceStatus.attended;
          case 'not_attending':
            return guest.status == EventAttendanceStatus.didNotAttend;
          default:
            return true;
        }
      }).toList();
    }
  }

  void _openFilterModal() {
    FilterBottomSheet.show(
      context: context,
      options: _filterOptions,
      selectedOption: _selectedFilter,
      onOptionSelected: (option) {
        setState(() {
          _selectedFilter = option;
          _applyFilter();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Misafir Listesi',
      actionIcon: LucideIcons.listFilter400,
      onActionTap: _openFilterModal,
      children: [
        CustomSearchBar(
          hintText: 'Misafir ara...',
          onChanged: (value) {
            // TODO: Implement search filter
          },
        ),
        SizedBox(height: 20.h),
        _buildGuestList(),
      ],
    );
  }

  Widget _buildGuestList() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredGuests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _selectedFilter.id == 'all'
                ? 'Henüz misafir yok'
                : 'Bu filtre için misafir bulunamadı',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppTheme.getTextDescColor(context),
            ),
          ),
        ),
      );
    }

    return Column(
      children: _filteredGuests.map((guest) {
        return GestureDetector(
          onTap: () => _showGuestModal(context, guest),
          behavior: HitTestBehavior.opaque,
          child: GuestListItem(
            profileImageUrl: guest.profileImageUrl ?? '',
            fullName: guest.fullName,
            username: guest.username, // GuestListItem zaten @ ekliyor
            statusText: guest.statusDisplayText,
            statusType: _getStatusType(guest.status),
          ),
        );
      }).toList(),
    );
  }

  BadgeType _getStatusType(EventAttendanceStatus status) {
    switch (status) {
      case EventAttendanceStatus.attending:
      case EventAttendanceStatus.pending:
        return BadgeType.orange;
      case EventAttendanceStatus.attended:
        return BadgeType.green;
      case EventAttendanceStatus.didNotAttend:
      case EventAttendanceStatus.rejected:
        return BadgeType.red;
      default:
        return BadgeType.black;
    }
  }

  void _showGuestModal(BuildContext context, GuestModel guest) {
    CustomModalSheet.show(
      context: context,
      showDivider: true,
      headerLeft: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22.5.r,
            backgroundImage: guest.profileImageUrl != null
                ? NetworkImage(guest.profileImageUrl!)
                : null,
            backgroundColor: AppTheme.zinc300,
          ),
          SizedBox(height: 10.h),
          Text(
            guest.fullName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextHeadColor(context),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Username Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanıcı Adı',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.zinc600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '@${guest.username}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextHeadColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Durum',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.zinc600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      guest.statusDisplayText,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextHeadColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildModalButton(
                  context: context,
                  label: 'Katılmadı',
                  onPressed: () => _markAsDidNotAttend(guest),
                  type: ModalButtonType.secondary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildModalButton(
                  context: context,
                  label: 'Katıldı',
                  onPressed: () => _markAsAttended(guest),
                  type: ModalButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required ModalButtonType type,
  }) {
    late final Color backgroundColor;
    late final Color textColor;
    late final Color borderColor;

    switch (type) {
      case ModalButtonType.primary:
        backgroundColor = AppTheme.black800;
        textColor = AppTheme.white;
        borderColor = AppTheme.black800;
        break;
      case ModalButtonType.secondary:
        backgroundColor = AppTheme.zinc200;
        textColor = AppTheme.red700;
        borderColor = AppTheme.zinc300;
        break;
    }

    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _markAsAttended(GuestModel guest) async {
    Navigator.of(context, rootNavigator: true).pop();

    try {
      await _service.updateAttendanceStatus(
        attendanceId: guest.id,
        newStatus: EventAttendanceStatus.attended,
      );

      if (mounted) {
        getIt<AppFeedbackService>().showSuccess(
          '${guest.fullName} katıldı olarak işaretlendi',
        );
        await _loadGuests(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        getIt<AppFeedbackService>().showError('İşlem başarısız');
      }
    }
  }

  Future<void> _markAsDidNotAttend(GuestModel guest) async {
    Navigator.of(context, rootNavigator: true).pop();

    try {
      await _service.updateAttendanceStatus(
        attendanceId: guest.id,
        newStatus: EventAttendanceStatus.didNotAttend,
      );

      if (mounted) {
        getIt<AppFeedbackService>().showSuccess(
          '${guest.fullName} katılmadı olarak işaretlendi',
        );
        await _loadGuests(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        getIt<AppFeedbackService>().showError('İşlem başarısız');
      }
    }
  }
}
