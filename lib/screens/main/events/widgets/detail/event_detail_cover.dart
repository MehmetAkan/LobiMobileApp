import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';


class EventDetailCover extends StatelessWidget {
  final String? coverPhotoUrl;

  const EventDetailCover({
    super.key,
    this.coverPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: AppImage(
          path: coverPhotoUrl,
          // cover boş veya hatalıysa kullanılacak default görsel
          fallbackPath: 'assets/images/system/event-example.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
