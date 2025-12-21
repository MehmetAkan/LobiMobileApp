import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/badges/status_badge.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';

class GuestListItem extends StatelessWidget {
  final String profileImageUrl;
  final String fullName;
  final String username;
  final String statusText;
  final BadgeType statusType;

  const GuestListItem({
    super.key,
    required this.profileImageUrl,
    required this.fullName,
    required this.username,
    required this.statusText,
    required this.statusType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Profile Picture - ProfileAvatar kullan
            ProfileAvatar(
              imageUrl: profileImageUrl.isNotEmpty ? profileImageUrl : null,
              name: fullName,
              size: 45,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextHeadColor(context),
                    ),
                  ),
                  if (username.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      '@$username',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.getTextDescColor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            StatusBadge(text: statusText, type: statusType),
          ],
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.only(left: 55.w), // İcona göre hizalı
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.getProfileDivider(context),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
