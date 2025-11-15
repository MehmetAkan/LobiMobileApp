import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventDetailDivider - Bölüm ayırıcı
/// 
/// CreateEventScreen'deki divider ile aynı stil
class EventDetailDivider extends StatelessWidget {
  const EventDetailDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppTheme.getAppBarButtonBorder(context).withOpacity(0.3),
      thickness: 1,
      height: 1,
    );
  }
}