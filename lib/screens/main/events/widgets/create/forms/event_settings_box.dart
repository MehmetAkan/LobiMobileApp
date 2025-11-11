import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventSettingsBox - Settings item'larını saran kutu
/// 
/// Özellikler:
/// - Rounded corners
/// - Background color
/// - Item'ları listeler
/// 
/// Kullanım:
/// ```dart
/// EventSettingsBox(
///   children: [
///     EventSettingsItem.switch(...),
///     EventSettingsItem.action(...),
///     EventSettingsItem.action(..., showDivider: false), // Son item
///   ],
/// )
/// ```
class EventSettingsBox extends StatelessWidget {
  /// İçerideki item'lar
  final List<Widget> children;

  const EventSettingsBox({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getEventFieldBg(context),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}