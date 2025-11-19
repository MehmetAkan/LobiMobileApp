import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventManageQuestionsScreen extends StatelessWidget {
  const EventManageQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kayıt Soruları',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.getAppBarTextColor(context),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: AppTheme.getAppBarTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppTheme.getAppBarBg(context),
      ),
      body: Center(
        child: Text(
          'Kayıt Soruları Sayfası',
          style: TextStyle(color: AppTheme.getTextHeadColor(context)),
        ),
      ),
    );
  }
}
