import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/services/event_attendance_service.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class EventManageCheckinScreen extends StatefulWidget {
  final EventModel event;

  const EventManageCheckinScreen({super.key, required this.event});

  @override
  State<EventManageCheckinScreen> createState() =>
      _EventManageCheckinScreenState();
}

class _EventManageCheckinScreenState extends State<EventManageCheckinScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  final EventAttendanceService _attendanceService = EventAttendanceService();

  bool _isFlashOn = false;
  bool _hasPermission = false;
  bool _isPermissionPermanentlyDenied = false;
  bool _isProcessing = false; // Prevent duplicate scans

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    debugPrint('Checking camera permission...');
    final status = await Permission.camera.status;
    debugPrint('Current camera status: $status');

    if (status.isGranted) {
      debugPrint('Permission granted.');
      setState(() {
        _hasPermission = true;
        _isPermissionPermanentlyDenied = false;
      });
    } else if (status.isDenied) {
      debugPrint('Permission denied (not determined yet), requesting...');
      final requestStatus = await Permission.camera.request();
      debugPrint('Request status: $requestStatus');

      setState(() {
        _hasPermission = requestStatus.isGranted;
        // On iOS, denied can mean permanently denied if it was already asked.
        // We check if it's permanently denied OR if it remains denied after request.
        _isPermissionPermanentlyDenied =
            requestStatus.isPermanentlyDenied ||
            (requestStatus.isDenied &&
                Theme.of(context).platform == TargetPlatform.iOS);
      });
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      debugPrint('Permission permanently denied or restricted.');
      setState(() {
        _hasPermission = false;
        _isPermissionPermanentlyDenied = true;
      });
    }
  }

  void _toggleFlash() {
    if (_hasPermission) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      _controller.toggleTorch();
    }
  }

  Future<void> _openSettings() async {
    debugPrint('Opening settings...');
    try {
      final opened = await openAppSettings();
      debugPrint('Settings opened: $opened');
      if (!opened && mounted) {
        _showSettingsErrorDialog();
      }
    } catch (e) {
      debugPrint('Error opening settings: $e');
      if (mounted) {
        _showSettingsErrorDialog();
      }
    }
  }

  void _showSettingsErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayarlar Açılamadı'),
        content: const Text(
          'Ayarlar sayfası otomatik olarak açılamadı. Lütfen cihazınızın ayarlarından uygulamanın kamera iznini manuel olarak açın.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scan area size
    final double scanAreaSize = 280.w;
    final double scanAreaTop = 200.h;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Layer
          if (_hasPermission)
            MobileScanner(
              controller: _controller,
              onDetect: (capture) async {
                if (_isProcessing) return;

                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    await _handleQRScan(barcode.rawValue!);
                    break; // Process only first barcode
                  }
                }
              },
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.cameraOff,
                        color: Colors.white,
                        size: 48.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _isPermissionPermanentlyDenied
                            ? 'Kamera erişimi engellendi.'
                            : 'Kamera izni gerekiyor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _isPermissionPermanentlyDenied
                            ? 'QR kod okuyabilmek için ayarlardan kamera iznini onaylamanız gerekmektedir.'
                            : 'Devam etmek için lütfen kamera izni verin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: _isPermissionPermanentlyDenied
                            ? _openSettings
                            : _checkPermission,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          _isPermissionPermanentlyDenied
                              ? 'Ayarları Aç'
                              : 'İzin Ver',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 2. Blur Overlay with Hole
          if (_hasPermission)
            ClipPath(
              clipper: InvertedRectClipper(
                rect: Rect.fromLTWH(
                  (MediaQuery.of(context).size.width - scanAreaSize) / 2,
                  scanAreaTop,
                  scanAreaSize,
                  scanAreaSize,
                ),
                radius: 20.r,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),

          // 3. Scanner Border
          Positioned(
            top: scanAreaTop,
            left: (MediaQuery.of(context).size.width - scanAreaSize) / 2,
            child: Container(
              width: scanAreaSize,
              height: scanAreaSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),

          // 4. App Bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FullPageAppBar(
              title: 'Misafir Katılımı İşaretle',
              style: AppBarStyle
                  .dark, // Transparent background style if available or default
            ),
          ),

          // 5. Flashlight Button
          if (_hasPermission)
            Positioned(
              top: scanAreaTop + scanAreaSize + 40.h,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleFlash,
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: _isFlashOn
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFlashOn ? LucideIcons.zap : LucideIcons.zapOff,
                      color: _isFlashOn ? Colors.black : Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Handle QR code scan
  Future<void> _handleQRScan(String qrData) async {
    setState(() => _isProcessing = true);

    try {
      // Parse JSON
      final data = jsonDecode(qrData) as Map<String, dynamic>;
      final attendanceId = data['attendance_id'] as String?;
      final verificationCode = data['verification_code'] as String?;

      if (attendanceId == null || verificationCode == null) {
        throw Exception('Geçersiz QR kod formatı');
      }

      // Verify check-in
      final result = await _attendanceService.verifyCheckIn(
        attendanceId: attendanceId,
        verificationCode: verificationCode,
        eventId: widget.event.id,
      );

      // Show success modal
      if (mounted) {
        _showSuccessModal(
          name: result['full_name'] as String? ?? 'İsimsiz',
          avatarUrl: result['avatar_url'] as String?,
        );
      }
    } catch (e) {
      // Show error modal
      if (mounted) {
        _showErrorModal(e.toString());
      }
    } finally {
      // Reset processing flag after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Show success modal
  void _showSuccessModal({required String name, String? avatarUrl}) {
    getIt<AppFeedbackService>().showSuccess(
      '$name katıldı olarak işaretlendi ✅',
    );

    // Optional: Show detailed modal (can be implemented later)
    // showDialog(...)
  }

  /// Show error modal
  void _showErrorModal(String error) {
    String message = error;

    // Simplify error messages
    if (error.contains('Bu kullanıcı zaten katıldı')) {
      message = 'Bu kullanıcı zaten katıldı olarak işaretlendi';
    } else if (error.contains('Geçersiz doğrulama kodu')) {
      message = 'Geçersiz QR kodu';
    } else if (error.contains('Bu QR kod bu etkinlik için geçerli değil')) {
      message = 'Bu QR kod bu etkinlik için geçerli değil';
    } else if (error.contains('katılım durumu uygun değil')) {
      message = 'Kullanıcının katılım durumu uygun değil';
    }

    getIt<AppFeedbackService>().showError(message);
  }
}

class InvertedRectClipper extends CustomClipper<Path> {
  final Rect rect;
  final double radius;

  InvertedRectClipper({required this.rect, this.radius = 0});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
