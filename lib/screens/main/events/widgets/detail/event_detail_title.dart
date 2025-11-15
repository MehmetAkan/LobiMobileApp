import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// EventDetailTitle - Etkinlik başlığı
/// 
/// Beyaz renk, 25px, bold
class EventDetailTitle extends StatelessWidget {
  final String title;

  const EventDetailTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 25.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.2,
      ),
    );
  }
}