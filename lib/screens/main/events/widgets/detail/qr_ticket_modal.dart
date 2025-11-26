import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/models/event_attendance_model.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRTicketModal extends StatelessWidget {
  final EventAttendanceModel attendance;
  final EventModel event;
  final String userName;
  final String? userAvatar;

  const QRTicketModal({
    super.key,
    required this.attendance,
    required this.event,
    required this.userName,
    this.userAvatar,
  });

  static void show(
    BuildContext context, {
    required EventAttendanceModel attendance,
    required EventModel event,
    required String userName,
    String? userAvatar,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      useSafeArea: true, // 🔹 Tüm telefonlarda safe area'ya saygı duy
      builder: (context) => QRTicketModal(
        attendance: attendance,
        event: event,
        userName: userName,
        userAvatar: userAvatar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // QR Data JSON format
    final qrData = jsonEncode({
      'attendance_id': attendance.id,
      'verification_code': attendance.verificationCode,
      'event_id': event.id,
    });

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppTheme.zinc1000,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.zinc300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: 16.h),

          // Close Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.x400,
                      size: 20.sp,
                      color: AppTheme.zinc300,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // CONTENT
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🔹 QR TAM ORTADA
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PrettyQrView.data(
                        data: qrData,
                        decoration: const PrettyQrDecoration(
                          shape: PrettyQrSmoothSymbol(color: Color(0xFF1C1917)),
                        ),
                      ),
                    ),
                  ),

                  // 🔹 BAŞLIK + AÇIKLAMA QR'NİN ÜSTÜNDE
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Etkinlik QR Biletiniz',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Bu QR kodu organizatöre gösterin',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.zinc400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
