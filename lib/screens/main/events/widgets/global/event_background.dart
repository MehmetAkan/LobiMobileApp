import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';

class EventBackground extends StatelessWidget {
  final String? coverPhotoUrl;
  
  const EventBackground({
    super.key,
    this.coverPhotoUrl,
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.4,
              child: Image.asset(
                'assets/images/system/event-example-white.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: AppTheme.getCreateEventBg(context).withOpacity(0.30),
            ),
          ),
        ],
      ),
    );
  }
}