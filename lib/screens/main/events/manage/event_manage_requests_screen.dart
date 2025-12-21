import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
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

class EventManageRequestsScreen extends StatefulWidget {
  final String eventId;

  const EventManageRequestsScreen({super.key, required this.eventId});

  @override
  State<EventManageRequestsScreen> createState() =>
      _EventManageRequestsScreenState();
}

class _EventManageRequestsScreenState extends State<EventManageRequestsScreen> {
  final EventAttendanceService _attendanceService = EventAttendanceService();
  FilterOption _selectedFilter = _filterOptions.first;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _filteredRequests =
      []; // Arama için filtrelenmiş liste
  bool _isLoading = true;
  String _searchQuery = ''; // Arama sorgusu

  static const List<FilterOption> _filterOptions = [
    FilterOption(
      id: 'all',
      label: 'Tümü',
      icon: LucideIcons.users400,
      isDefault: true,
    ),
    FilterOption(id: 'pending', label: 'Bekliyor', icon: LucideIcons.clock400),
    FilterOption(
      id: 'approved',
      label: 'Onaylandı',
      icon: LucideIcons.badgeCheck400,
    ),
    FilterOption(
      id: 'rejected',
      label: 'Reddedildi',
      icon: LucideIcons.badgeX400,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('🔍 Loading requests for event: ${widget.eventId}');

      EventAttendanceStatus? filterStatus;

      if (_selectedFilter.id == 'pending') {
        filterStatus = EventAttendanceStatus.pending;
      } else if (_selectedFilter.id == 'approved') {
        filterStatus = EventAttendanceStatus.attending;
      } else if (_selectedFilter.id == 'rejected') {
        filterStatus = EventAttendanceStatus.rejected;
      }

      debugPrint('🔍 Filter status: $filterStatus');

      final data = await _attendanceService.getAttendeesWithUserInfo(
        eventId: widget.eventId,
        filterStatus: filterStatus,
        includeCancelled: false,
      );

      debugPrint('🔍 Received ${data.length} requests');
      debugPrint('🔍 Raw data: $data');

      if (mounted) {
        setState(() {
          _requests = data;
          _filteredRequests = data; // İlk yüklemede tüm istekleri göster
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ İstekler yüklenirken hata: $e');
      debugPrint('⚠️ Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        getIt<AppFeedbackService>().showError('İstekler yüklenemedi');
      }
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
        });
        _loadRequests();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Katılım İstekleri',
      actionIcon: LucideIcons.listFilter400,
      onActionTap: _openFilterModal,
      children: [
        CustomSearchBar(
          hintText: 'Kullanıcı Ara',
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
              _filterRequests();
            });
          },
        ),
        SizedBox(height: 20.h),
        _isLoading ? _buildLoading() : _buildRequestList(),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: CircularProgressIndicator(color: AppTheme.zinc800),
      ),
    );
  }

  void _filterRequests() {
    if (_searchQuery.isEmpty) {
      _filteredRequests = _requests;
    } else {
      _filteredRequests = _requests.where((request) {
        final profile = request['profiles'] as Map<String, dynamic>?;
        final firstName = (profile?['first_name'] as String? ?? '')
            .toLowerCase();
        final lastName = (profile?['last_name'] as String? ?? '').toLowerCase();
        final username = (profile?['username'] as String? ?? '').toLowerCase();

        return firstName.contains(_searchQuery) ||
            lastName.contains(_searchQuery) ||
            username.contains(_searchQuery);
      }).toList();
    }
  }

  Widget _buildRequestList() {
    if (_filteredRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.h),
          child: Text(
            _searchQuery.isEmpty
                ? 'İstek bulunamadı'
                : 'Arama sonucu bulunamadı',
            style: TextStyle(fontSize: 16.sp, color: AppTheme.zinc600),
          ),
        ),
      );
    }

    return Column(
      children: _filteredRequests.map((request) {
        final profile = request['profiles'] as Map<String, dynamic>?;
        final firstName = profile?['first_name'] as String? ?? '';
        final lastName = profile?['last_name'] as String? ?? '';
        final fullName = '$firstName $lastName'.trim();
        final username = profile?['username'] as String? ?? ''; // Username'i al
        final avatarUrl = profile?['avatar_url'] as String?;
        final status = request['status'] as String;
        final userId = request['user_id'] as String;

        return GestureDetector(
          onTap: () => _showRequestModal(
            context,
            fullName.isEmpty ? 'Kullanıcı' : fullName,
            username, // Username'i modal'a gönder
            avatarUrl,
            userId,
            status,
          ),
          behavior: HitTestBehavior.opaque,
          child: GuestListItem(
            profileImageUrl: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? avatarUrl
                : '',
            fullName: fullName.isEmpty ? 'Kullanıcı' : fullName,
            username: username, // Username'i göster
            statusText: _getStatusText(status),
            statusType: _getStatusType(status),
          ),
        );
      }).toList(),
    );
  }

  void _showRequestModal(
    BuildContext context,
    String fullName,
    String username, // Username parametresi eklendi
    String? profileImageUrl,
    String userId,
    String currentStatus,
  ) {
    CustomModalSheet.show(
      context: context,
      showDivider: true,
      headerLeft: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22.5.r,
            backgroundImage: profileImageUrl != null
                ? NetworkImage(profileImageUrl)
                : null,
            backgroundColor: AppTheme.zinc300,
            child: profileImageUrl == null
                ? Icon(
                    LucideIcons.user400,
                    size: 24.sp,
                    color: AppTheme.zinc600,
                  )
                : null,
          ),
          SizedBox(height: 10.h),
          Text(
            fullName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextHeadColor(context),
            ),
          ),
        ],
      ),
      child: Row(
        children: [
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
                  username.isNotEmpty ? '@$username' : '-',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextHeadColor(context),
                  ),
                ),
              ],
            ),
          ),
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
                  _getStatusText(currentStatus),
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
      footer: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: currentStatus == 'pending'
                  ? () => _handleReject(userId)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                foregroundColor: AppTheme.red700,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                side: BorderSide(color: AppTheme.zinc300, width: 1),
              ),
              child: Text(
                'Reddet',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: currentStatus == 'pending'
                  ? () => _handleApprove(userId)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black800,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Onayla',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(String userId) async {
    Navigator.of(context, rootNavigator: true).pop();

    try {
      await _attendanceService.approveAttendance(
        eventId: widget.eventId,
        userId: userId,
      );

      if (mounted) {
        getIt<AppFeedbackService>().showSuccess('İstek onaylandı');
        _loadRequests(); // Refresh list
      }
    } catch (e) {
      debugPrint('⚠️ Onaylama hatası: $e');
      if (mounted) {
        getIt<AppFeedbackService>().showError('Onaylama başarısız');
      }
    }
  }

  Future<void> _handleReject(String userId) async {
    Navigator.of(context, rootNavigator: true).pop();

    try {
      await _attendanceService.rejectAttendance(
        eventId: widget.eventId,
        userId: userId,
        reason: 'Organizatör tarafından reddedildi',
      );

      if (mounted) {
        getIt<AppFeedbackService>().showWarning('İstek reddedildi');
        _loadRequests(); // Refresh list
      }
    } catch (e) {
      debugPrint('⚠️ Reddetme hatası: $e');
      if (mounted) {
        getIt<AppFeedbackService>().showError('Reddetme başarısız');
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'attending':
        return 'Onaylandı';
      case 'rejected':
        return 'Reddedildi';
      default:
        return '';
    }
  }

  BadgeType _getStatusType(String status) {
    switch (status) {
      case 'pending':
        return BadgeType.orange;
      case 'attending':
        return BadgeType.green;
      case 'rejected':
        return BadgeType.red;
      default:
        return BadgeType.black;
    }
  }
}
