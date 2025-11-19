import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';

class EventBackground extends StatelessWidget {
  final String? coverPhotoUrl;


  final String? defaultCoverAsset;

  const EventBackground({
    super.key,
    this.coverPhotoUrl,
    this.defaultCoverAsset, 
  });

@override
Widget build(BuildContext context) {
  return Positioned.fill(
    child: Stack(
      children: [
        Positioned.fill(
          child: Transform.scale(
            scale: 1.4,
            child: AppImage(
              path: coverPhotoUrl,
              fallbackPath:
                  defaultCoverAsset ?? 'assets/images/system/event-example-black.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(
              color: AppTheme.getCreateEventBg(context).withOpacity(0.40),
            ),
          ),
        ),
      ],
    ),
  );
}

}
