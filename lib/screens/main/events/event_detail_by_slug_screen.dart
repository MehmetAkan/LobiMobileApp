import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/data/repositories/event_repository.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// Deep link ile açılan event detail ekranı
///
/// Share slug kullanarak event'i yükler ve EventDetailScreen'e yönlendirir
class EventDetailBySlugScreen extends ConsumerStatefulWidget {
  final String shareSlug;

  const EventDetailBySlugScreen({super.key, required this.shareSlug});

  @override
  ConsumerState<EventDetailBySlugScreen> createState() =>
      _EventDetailBySlugScreenState();
}

class _EventDetailBySlugScreenState
    extends ConsumerState<EventDetailBySlugScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      AppLogger.info('🔍 Loading event by slug: ${widget.shareSlug}');

      final eventRepository = getIt<EventRepository>();
      final event = await eventRepository.getEventBySlug(widget.shareSlug);

      if (!mounted) return;

      if (event == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Etkinlik bulunamadı';
        });
        AppLogger.warning('⚠️ Event not found for slug: ${widget.shareSlug}');
        return;
      }

      AppLogger.info('✅ Event loaded: ${event.title}');

      // Event detail ekranına yönlendir (replace current route)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Event load error', e, stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Etkinlik yüklenemedi';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(
                'Etkinlik yükleniyor...',
                style: TextStyle(fontSize: 16.sp, color: AppTheme.zinc600),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return StandardPage(
        title: 'Hata',
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(40.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppTheme.zinc400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextHeadColor(context),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Geri Dön'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Should not reach here
    return const SizedBox.shrink();
  }
}
