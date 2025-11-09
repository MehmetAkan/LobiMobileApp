import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class EventSettingsItem extends StatelessWidget {
  final IconData icon;

  final String label;

  final EventSettingsItemType type;

  final bool? switchValue;
  final Function(bool)? onSwitchChanged;

  final String? actionValue;
  final String actionPlaceholder; 
  final VoidCallback? onTap;

  final bool showDivider;

  const EventSettingsItem._({
    super.key,
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

  factory EventSettingsItem.switchType({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
    bool showDivider = true,
  }) {
    return EventSettingsItem._(
      icon: icon,
      label: label,
      type: EventSettingsItemType.switchType,
      switchValue: value,
      onSwitchChanged: onChanged,
      showDivider: showDivider,
    );
  }
  factory EventSettingsItem.action({
    required IconData icon,
    required String label,
    String? value,
    String placeholder = 'Seç', 
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return EventSettingsItem._(
      icon: icon,
      label: label,
      type: EventSettingsItemType.action,
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
        type == EventSettingsItemType.action
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
              color: AppTheme.white.withOpacity(0.1),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final verticalPadding = type == EventSettingsItemType.switchType ? 5.h : 15.h;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: verticalPadding),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: AppTheme.getEventFieldPlaceholder(context),
          ),
          SizedBox(width: 10.w),
          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.getEventFieldPlaceholder(context),
                height: 1.2,
              ),
            ),
          ),
          // Right side (Switch veya Action)
          _buildRightSide(context),
        ],
      ),
    );
  }

  Widget _buildRightSide(BuildContext context) {
    switch (type) {
      case EventSettingsItemType.switchType:
        return Switch.adaptive(
          value: switchValue ?? false,
          onChanged: onSwitchChanged,
        );

      case EventSettingsItemType.action:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              actionValue ?? actionPlaceholder, 
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: actionValue != null
                    ? AppTheme.getEventFieldText(context)
                    : AppTheme.getEventFieldPlaceholder(context),
                height: 1.2,
              ),
            ),
            SizedBox(width: 5.w),
            Icon(
              LucideIcons.chevronsUpDown400,
              size: 18.sp,
              color: AppTheme.getEventFieldPlaceholder(context),
            ),
          ],
        );
    }
  }
}
enum EventSettingsItemType {
  switchType,
  action,
}