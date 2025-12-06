import 'package:share_plus/share_plus.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/core/utils/date_extensions.dart';
import 'package:lobi_application/core/utils/logger.dart';

/// Share servisi
///
/// Etkinlik paylaşma işlemlerini yönetir:
/// - Deep link URL oluşturma
/// - Native share dialog gösterme
/// - WhatsApp, Instagram, vb. platformlara paylaşım
class ShareService {
  static const String _baseUrl = 'https://go.lobiapp.co';

  /// Etkinlik için paylaşılabilir link oluştur
  String generateEventLink(String shareSlug) {
    final link = '$_baseUrl/$shareSlug';
    AppLogger.info('🔗 Event link generated: $link');
    return link;
  }

  /// Etkinliği native share dialog ile paylaş
  Future<void> shareEvent(EventModel event) async {
    try {
      final link = generateEventLink(event.shareSlug);

      // Paylaşım metni oluştur
      final text = _buildShareText(event, link);

      AppLogger.info('📤 Sharing event: ${event.title}');

      // Native share dialog aç
      final result = await Share.share(
        text,
        subject: event.title, // Email subject için
      );

      if (result.status == ShareResultStatus.success) {
        AppLogger.info('✅ Event shared successfully');
      } else if (result.status == ShareResultStatus.dismissed) {
        AppLogger.info('⚪ Share dialog dismissed');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Share event error', e, stackTrace);
      rethrow;
    }
  }

  /// Paylaşım metni oluştur
  String _buildShareText(EventModel event, String link) {
    final buffer = StringBuffer();

    // Emoji + Başlık
    buffer.writeln('🎉 Etkinliğe Katıl!');
    buffer.writeln();

    // Etkinlik başlığı
    buffer.writeln(event.title);

    // Tarih
    final formattedDate = event.date.toTodayTomorrowWithTime();
    buffer.writeln('📅 $formattedDate');

    // Konum
    if (event.location.isNotEmpty) {
      buffer.writeln('📍 ${event.location}');
    }

    // Link
    buffer.writeln();
    buffer.write(link);

    return buffer.toString();
  }

  /// WhatsApp'a direkt paylaş (optional - daha gelişmiş)
  Future<void> shareToWhatsApp(EventModel event) async {
    try {
      final link = generateEventLink(event.shareSlug);
      final text = _buildShareText(event, link);

      // WhatsApp URL scheme
      final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(text)}';

      // Share with specific URL
      await Share.shareUri(Uri.parse(whatsappUrl));

      AppLogger.info('✅ Shared to WhatsApp');
    } catch (e, stackTrace) {
      AppLogger.error('Share to WhatsApp error', e, stackTrace);

      // Fallback to normal share
      await shareEvent(event);
    }
  }
}
