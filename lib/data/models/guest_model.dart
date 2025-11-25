import 'package:lobi_application/data/models/event_attendance_status.dart';

/// GuestModel - Misafir listesi için kullanıcı + katılım bilgisi
///
/// event_participants JOIN profiles sonucu
class GuestModel {
  final String id; // attendance id
  final String userId;
  final String fullName;
  final String username;
  final String? profileImageUrl;
  final EventAttendanceStatus status;
  final DateTime joinedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? attendedAt;

  const GuestModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.username,
    this.profileImageUrl,
    required this.status,
    required this.joinedAt,
    this.approvedAt,
    this.rejectedAt,
    this.attendedAt,
  });

  /// Supabase join query'den parse
  factory GuestModel.fromJson(Map<String, dynamic> json) {
    // Nested profiles object
    final profiles = json['profiles'] as Map<String, dynamic>?;

    // Combine first_name and last_name
    final firstName = profiles?['first_name'] as String? ?? '';
    final lastName = profiles?['last_name'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return GuestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: fullName.isNotEmpty ? fullName : 'İsimsiz',
      username:
          json['user_id'] as String? ??
          'kullanici', // TODO: username if available
      profileImageUrl: profiles?['avatar_url'] as String?,
      status: EventAttendanceStatus.fromDbValue(json['status'] as String?),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      attendedAt: json['attended_at'] != null
          ? DateTime.parse(json['attended_at'] as String)
          : null,
    );
  }

  /// Display text for status
  String get statusDisplayText {
    switch (status) {
      case EventAttendanceStatus.pending:
        return 'Onay Bekliyor';
      case EventAttendanceStatus.attending:
        return 'Katılacak';
      case EventAttendanceStatus.attended:
        return 'Katıldı';
      case EventAttendanceStatus.didNotAttend:
        return 'Katılmadı';
      case EventAttendanceStatus.rejected:
        return 'Reddedildi';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'GuestModel(id: $id, fullName: $fullName, status: ${status.dbValue})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
