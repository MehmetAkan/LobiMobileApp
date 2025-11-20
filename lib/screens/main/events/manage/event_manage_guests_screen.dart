import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/guest_list_item.dart';

import 'package:lobi_application/widgets/common/badges/status_badge.dart';

import 'package:lobi_application/widgets/common/inputs/custom_search_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventManageGuestsScreen extends StatefulWidget {
  const EventManageGuestsScreen({super.key});

  @override
  State<EventManageGuestsScreen> createState() =>
      _EventManageGuestsScreenState();
}

class _EventManageGuestsScreenState extends State<EventManageGuestsScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Katılacaklar',
    'Katıldı',
    'Davet Edildi',
    'Katılmayacaklar',
  ];

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Misafir Listesi',
      actionIcon: LucideIcons.search,
      onActionTap: () {
        // TODO: Implement search action
      },
      children: [
        CustomSearchBar(
          hintText: 'Misafir ara...',
          onChanged: (value) {
            // TODO: Implement search filter
          },
        ),
        SizedBox(height: 20.h),

        // Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 6.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.zinc200 : Colors.transparent,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? AppTheme.black800 : AppTheme.zinc900,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 20.h),
        _buildGuestList(),
      ],
    );
  }

  Widget _buildGuestList() {
    return Column(
      children: List.generate(5, (index) {
        return GuestListItem(
          profileImageUrl:
              'https://i.pravatar.cc/150?u=${index + _selectedTabIndex}', // Random image
          fullName: 'Kullanıcı Adı $index',
          username: 'kullanici$index',
          statusText: _getStatusText(),
          statusType: _getStatusType(),
        );
      }),
    );
  }

  String _getStatusText() {
    switch (_selectedTabIndex) {
      case 0:
        return 'Katılıyor';
      case 1:
        return 'Katıldı';
      case 2:
        return 'Davet Edildi';
      case 3:
        return 'Katılmıyor';
      default:
        return '';
    }
  }

  BadgeType _getStatusType() {
    switch (_selectedTabIndex) {
      case 0:
        return BadgeType.green;
      case 1:
        return BadgeType.purple;
      case 2:
        return BadgeType.black;
      case 3:
        return BadgeType.red;
      default:
        return BadgeType.black;
    }
  }
}
