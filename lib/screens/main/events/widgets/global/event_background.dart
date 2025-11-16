import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';

class EventBackground extends StatelessWidget {
  final String? coverPhotoUrl;

  /// CreateEventScreen'de random asset gönderebilmek için,
  /// ama verilmezse eski default görseli kullanacağız.
  final String? defaultCoverAsset;

  const EventBackground({
    super.key,
    this.coverPhotoUrl,
    this.defaultCoverAsset, // ❗ ARTIK required DEĞİL
  });

  /// Varsayılan arka plan görseli
  Widget _buildDefaultImage() {
    return Image.asset(
      // Eğer dışarıdan bir asset verildiyse onu kullan,
      // verilmediyse eski görsel ile devam et
      defaultCoverAsset ?? 'assets/images/system/event-example-black.png',
      fit: BoxFit.cover,
    );
  }

  Widget _buildBackgroundImage(String? url) {
    if (url == null) {
      return _buildDefaultImage();
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    }

    try {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    } catch (e) {
      return _buildDefaultImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.4,
              child: _buildBackgroundImage(coverPhotoUrl),
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
