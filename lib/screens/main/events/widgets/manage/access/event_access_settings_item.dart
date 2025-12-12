import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventAccessSettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final EventAccessSettingsItemType type;

  final bool? switchValue;
  final Function(bool)? onSwitchChanged;

  final String? actionValue;
  final String actionPlaceholder;
  final VoidCallback? onTap;

  final bool showDivider;

  const EventAccessSettingsItem._({
    required this.icon,
    required this.label,
    required this.type,
    this.switchValue,
    this.onSwitchChanged,
    this.actionValue,
    this.actionPlaceholder = 'Seç',
    this.onTap,
    this.showDivider = true,
  });

  factory EventAccessSettingsItem.switchType({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
    bool showDivider = true,
  }) {
    return EventAccessSettingsItem._(
      icon: icon,
      label: label,
      type: EventAccessSettingsItemType.switchType,
      switchValue: value,
      onSwitchChanged: onChanged,
      showDivider: showDivider,
    );
  }

  factory EventAccessSettingsItem.action({
    required IconData icon,
    required String label,
    String? value,
    String placeholder = 'Seç',
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return EventAccessSettingsItem._(
      icon: icon,
      label: label,
      type: EventAccessSettingsItemType.action,
      actionValue: value,
      actionPlaceholder: placeholder,
      onTap: onTap,
      showDivider: showDivider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        type == EventAccessSettingsItemType.action
            ? GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: _buildContent(context),
              )
            : _buildContent(context),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: 20.w + 20.sp + 10.w),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.getSettingsCardDivider(context),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final verticalPadding = type == EventAccessSettingsItemType.switchType
        ? 5.h
        : 15.h;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppTheme.getSettingsCardIcon(context)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextHeadColor(context),
                height: 1.2,
              ),
            ),
          ),
          _buildRightSide(context),
        ],
      ),
    );
  }

  Widget _buildRightSide(BuildContext context) {
    switch (type) {
      case EventAccessSettingsItemType.switchType:
        return Switch.adaptive(
          value: switchValue ?? false,
          onChanged: onSwitchChanged,
        );

      case EventAccessSettingsItemType.action:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              actionValue ?? actionPlaceholder,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: actionValue != null
                    ? AppTheme.getTextHeadColor(context)
                    : AppTheme.getSettingsCardIcon(context),
                height: 1.2,
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              LucideIcons.chevronsUpDown400,
              size: 18.sp,
              color: AppTheme.zinc600,
            ),
          ],
        );
    }
  }
}

enum EventAccessSettingsItemType { switchType, action }
