import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_modal_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventDetailLocation - Konum bilgisi + statik harita
///
/// - Üstte Google Static Map görüntüsü (oynamayan, scroll olmayan)
/// - Altta konum adı ve adres
/// - Tüm karta tıklayınca bottom sheet açılır ve harita uygulamasında açar
class EventDetailLocation extends StatelessWidget {
  final String locationName;
  final String locationAddress;

  const EventDetailLocation({
    super.key,
    required this.locationName,
    required this.locationAddress,
  });

  /// Google Static Map URL (API key .env içinden alınır)
  String? get _staticMapUrl {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

    // Adres + isim tek string
    final queryBase =
        (locationAddress.isNotEmpty
                ? '$locationName, $locationAddress'
                : locationName)
            .trim();

    if (apiKey == null || apiKey.isEmpty || queryBase.isEmpty) {
      return null;
    }

    final encodedQuery = Uri.encodeComponent(queryBase);

    final params = [
      'center=$encodedQuery',
      'zoom=15',
      'size=600x320', // 600x320, scale=2 ile retina gibi
      'scale=2',
      'maptype=roadmap',
      'markers=color:red%7C$encodedQuery',
      'key=$apiKey',
    ].join('&');

    return 'https://maps.googleapis.com/maps/api/staticmap?$params';
  }

  @override
  Widget build(BuildContext context) {
    final mapUrl = _staticMapUrl;

    return GestureDetector(
      onTap: () => _onTapOpenMap(context),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locationName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.2,
              ),
            ),
            SizedBox(height: 15.h),
            if (mapUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    mapUrl,
                    fit: BoxFit.cover,
                    // Yüklenirken skeleton
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.black.withOpacity(0.15),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    // Hata olursa eski ikonlu görünüm
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackRow(context);
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ] else ...[
              // API key yoksa veya query boşsa eski görünüm
              _buildFallbackRow(context),
              SizedBox(height: 8.h),
            ],

            // Konum adı

            // Adres
            if (locationAddress.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                locationAddress,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Konum ikonu
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.getAppBarButtonBg(context).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            LucideIcons.mapPin400,
            size: 20.sp,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        SizedBox(width: 12.w),

        // Konum bilgileri
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locationName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              if (locationAddress.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  locationAddress,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onTapOpenMap(BuildContext context) async {
    final query =
        (locationAddress.isNotEmpty
                ? '$locationName, $locationAddress'
                : locationName)
            .trim();

    if (query.isEmpty) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final displayTitle = locationName.isNotEmpty ? locationName : 'Konum';
        final detailText = locationAddress.isNotEmpty
            ? locationAddress
            : 'Konumu harita uygulamasında açmak ister misin?';

        return EventModalSheet(
          icon: LucideIcons.mapPin,
          title: displayTitle,
          description: detailText,
          // Eğer EventModalSheet'e daha önce descriptionMaxLines eklediysen:
          // descriptionMaxLines: 1,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Harita uygulamasında aç butonu
                  GestureDetector(
                    onTap: () => Navigator.of(sheetContext).pop(true),
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.externalLink,
                              size: 18.sp,
                              color: AppTheme.black800,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Harita uygulamasında aç',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.black800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Vazgeç
                  GestureDetector(
                    onTap: () => Navigator.of(sheetContext).pop(false),
                    child: Text(
                      'Vazgeç',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.getEventFieldPlaceholder(sheetContext),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
