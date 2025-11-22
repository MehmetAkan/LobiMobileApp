import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  const EventManageRequestsScreen({super.key});

  @override
  State<EventManageRequestsScreen> createState() =>
      _EventManageRequestsScreenState();
}

class _EventManageRequestsScreenState extends State<EventManageRequestsScreen> {
  FilterOption _selectedFilter = _filterOptions.first;

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

  void _openFilterModal() {
    FilterBottomSheet.show(
      context: context,
      options: _filterOptions,
      selectedOption: _selectedFilter,
      onOptionSelected: (option) {
        setState(() {
          _selectedFilter = option;
        });
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
        CustomSearchBar(hintText: 'Kullanıcı Ara', onChanged: (value) {}),
        SizedBox(height: 20.h),
        _buildRequestList(),
      ],
    );
  }

  Widget _buildRequestList() {
    // Mock data generation based on filter
    return Column(
      children: List.generate(10, (index) {
        // Simulate filtering for demo purposes
        if (_selectedFilter.id != 'all') {
          if (_selectedFilter.id == 'pending' && index % 3 != 0)
            return const SizedBox.shrink();
          if (_selectedFilter.id == 'approved' && index % 3 != 1)
            return const SizedBox.shrink();
          if (_selectedFilter.id == 'rejected' && index % 3 != 2)
            return const SizedBox.shrink();
        }

        final fullName = 'Kullanıcı Adı $index';
        final profileImageUrl = 'https://i.pravatar.cc/150?u=${index + 200}';

        return GestureDetector(
          onTap: () => _showRequestModal(context, fullName, profileImageUrl),
          behavior: HitTestBehavior.opaque,
          child: GuestListItem(
            profileImageUrl: profileImageUrl,
            fullName: fullName,
            username: 'kullanici$index',
            statusText: _getStatusText(index),
            statusType: _getStatusType(index),
          ),
        );
      }),
    );
  }

  void _showRequestModal(
    BuildContext context,
    String fullName,
    String profileImageUrl,
  ) {
    CustomModalSheet.show(
      context: context,
      showDivider: true,
      headerLeft: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22.5.r,
            backgroundImage: NetworkImage(profileImageUrl),
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
                  '@kullanici',
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
                  'Bekliyor',
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
              onPressed: () {
                Navigator.pop(context);
                // TODO: Service integration - Reject request
                debugPrint('🚫 İstek reddedildi');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                foregroundColor: AppTheme.red900,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                side: BorderSide(color: AppTheme.zinc300, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Reddet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                debugPrint('✅ İstek onaylandı');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black800,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Onayla',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int index) {
    final mod = index % 3;
    switch (mod) {
      case 0:
        return 'Bekliyor';
      case 1:
        return 'Onaylandı';
      case 2:
        return 'Reddedildi';
      default:
        return '';
    }
  }

  BadgeType _getStatusType(int index) {
    final mod = index % 3;
    switch (mod) {
      case 0:
        return BadgeType.orange;
      case 1:
        return BadgeType.green;
      case 2:
        return BadgeType.red;
      default:
        return BadgeType.black;
    }
  }
}
