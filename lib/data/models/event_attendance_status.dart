import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum EventAttendanceStatus {
  notAttending,

  pending,

  attending,

  attended, // ✅ NEW: Etkinlikte katıldı

  didNotAttend, // ✅ NEW: Etkinlikte katılmadı

  rejected;

  String get displayText {
    switch (this) {
      case EventAttendanceStatus.notAttending:
        return '';
      case EventAttendanceStatus.pending:
        return 'Organizatör Onayı Bekleniyor';
      case EventAttendanceStatus.attending:
        return 'Katılacaksınız';
      case EventAttendanceStatus.attended:
        return 'Katıldı';
      case EventAttendanceStatus.didNotAttend:
        return 'Katılmadı';
      case EventAttendanceStatus.rejected:
        return 'Katılım Talebiniz Reddedildi';
    }
  }

  /// Badge rengi (AppTheme'den)
  Color getBadgeColor(BuildContext context) {
    switch (this) {
      case EventAttendanceStatus.notAttending:
        return AppTheme.zinc500;
      case EventAttendanceStatus.pending:
        return AppTheme.orange600;
      case EventAttendanceStatus.attending:
        return AppTheme.green500;
      case EventAttendanceStatus.attended:
        return AppTheme.green500; // Katıldı - yeşil
      case EventAttendanceStatus.didNotAttend:
        return AppTheme.red600; // Katılmadı - kırmızı
      case EventAttendanceStatus.rejected:
        return AppTheme.red600;
    }
  }

  /// Badge icon (Lucide Icons)
  IconData get iconData {
    switch (this) {
      case EventAttendanceStatus.notAttending:
        return LucideIcons.userX400;
      case EventAttendanceStatus.pending:
        return LucideIcons.clock400;
      case EventAttendanceStatus.attending:
        return LucideIcons.badgeCheck400;
      case EventAttendanceStatus.attended:
        return LucideIcons.check400; // Katıldı - check
      case EventAttendanceStatus.didNotAttend:
        return LucideIcons.x400; // Katılmadı - X
      case EventAttendanceStatus.rejected:
        return LucideIcons.circleX400;
    }
  }

  /// Katılım talebi gönderilebilir mi?
  bool get canRequestAttendance {
    return this == EventAttendanceStatus.notAttending ||
        this == EventAttendanceStatus.rejected;
  }

  /// Katılımdan ayrılabilir mi?
  bool get canLeaveEvent {
    return this == EventAttendanceStatus.attending ||
        this == EventAttendanceStatus.pending;
  }

  /// Supabase'deki karşılığı
  String get dbValue {
    switch (this) {
      case EventAttendanceStatus.notAttending:
        return 'not_attending';
      case EventAttendanceStatus.pending:
        return 'pending';
      case EventAttendanceStatus.attending:
        return 'attending';
      case EventAttendanceStatus.attended:
        return 'attended';
      case EventAttendanceStatus.didNotAttend:
        return 'did_not_attend';
      case EventAttendanceStatus.rejected:
        return 'rejected';
    }
  }

  /// Supabase'den gelen değeri enum'a çevir
  static EventAttendanceStatus fromDbValue(String? value) {
    switch (value) {
      case 'pending':
        return EventAttendanceStatus.pending;
      case 'attending':
        return EventAttendanceStatus.attending;
      case 'attended':
        return EventAttendanceStatus.attended;
      case 'did_not_attend':
        return EventAttendanceStatus.didNotAttend;
      case 'rejected':
        return EventAttendanceStatus.rejected;
      default:
        return EventAttendanceStatus.notAttending;
    }
  }
}
