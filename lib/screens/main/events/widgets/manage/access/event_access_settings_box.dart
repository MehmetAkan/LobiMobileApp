import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

class EventAccessSettingsBox extends StatelessWidget {
  final List<Widget> children;

  const EventAccessSettingsBox({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSettingsCardBg(context),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
