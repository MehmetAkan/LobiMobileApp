import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/guest_list_item.dart';

import 'package:lobi_application/widgets/common/badges/status_badge.dart';

import 'package:lobi_application/widgets/common/inputs/custom_search_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:lobi_application/widgets/common/filters/filter_bottom_sheet.dart';
import 'package:lobi_application/widgets/common/filters/filter_option.dart';

class EventManageGuestsScreen extends StatefulWidget {
  const EventManageGuestsScreen({super.key});

  @override
  State<EventManageGuestsScreen> createState() =>
      _EventManageGuestsScreenState();
}

class _EventManageGuestsScreenState extends State<EventManageGuestsScreen> {
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
      id: 'invited',
      label: 'Davet Edildi',
      icon: LucideIcons.mail400,
    ),
    FilterOption(
      id: 'not_attending',
      label: 'Katılmayacaklar',
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
    // Mock data generation based on filter
    // In a real app, this would filter the actual list
    return Column(
      children: List.generate(10, (index) {
        // Simulate filtering for demo purposes
        if (_selectedFilter.id != 'all') {
          // Simple logic to show different items for different filters
          if (_selectedFilter.id == 'attending' && index % 4 != 0)
            return const SizedBox.shrink();
          if (_selectedFilter.id == 'attended' && index % 4 != 1)
            return const SizedBox.shrink();
          if (_selectedFilter.id == 'invited' && index % 4 != 2)
            return const SizedBox.shrink();
          if (_selectedFilter.id == 'not_attending' && index % 4 != 3)
            return const SizedBox.shrink();
        }

        return GuestListItem(
          profileImageUrl:
              'https://i.pravatar.cc/150?u=${index + 100}', // Random image
          fullName: 'Kullanıcı Adı $index',
          username: 'kullanici$index',
          statusText: _getStatusText(index),
          statusType: _getStatusType(index),
        );
      }),
    );
  }

  String _getStatusText(int index) {
    // Mock status text based on index to simulate mixed list
    final mod = index % 4;
    switch (mod) {
      case 0:
        return 'Katılacak';
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

  BadgeType _getStatusType(int index) {
    // Mock status type based on index
    final mod = index % 4;
    switch (mod) {
      case 0:
        return BadgeType.purple;
      case 1:
        return BadgeType.green;
      case 2:
        return BadgeType.black;
      case 3:
        return BadgeType.red;
      default:
        return BadgeType.black;
    }
  }
}
