import 'package:lobi_application/core/utils/logger.dart';

/// Notification Type Enum
enum NotificationType {
  attendanceApproved('attendance_approved'),
  eventReminder('event_reminder'),
  newParticipant('new_participant'),
  eventAnnouncement('event_announcement'),
  newEventsInCategory('new_events_in_category'),
  eventRejected('event_rejected');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () {
        AppLogger.warning('Unknown notification type: $value');
        return NotificationType.eventAnnouncement;
      },
    );
  }
}

/// Notification Model
class NotificationModel {
  final String id;
  final String userId;
  final String? eventId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.eventId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.sentAt,
    this.deliveredAt,
    this.data,
    required this.createdAt,
  });

  /// From JSON (Supabase)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String?,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'type': type.value,
      'title': title,
      'body': body,
      'is_read': isRead,
      'sent_at': sentAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? sentAt,
    DateTime? deliveredAt,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
