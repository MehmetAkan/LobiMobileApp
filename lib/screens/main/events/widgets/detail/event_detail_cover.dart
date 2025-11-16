import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// EventDetailCover - Etkinlik detay sayfası cover fotoğrafı
/// 
/// Create event'teki cover section ile benzer yapı
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
        aspectRatio: 4 /3,
        child: _buildCoverImage(coverPhotoUrl),
      ),
    );
  }

  Widget _buildCoverImage(String? url) {
    final defaultImage = Image.asset(
      'assets/images/system/event-example.png',
      fit: BoxFit.cover,
    );

    if (url == null) {
      return defaultImage;
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return defaultImage;
        },
      );
    }

    try {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return defaultImage;
        },
      );
    } catch (e) {
      return defaultImage;
    }
  }
}