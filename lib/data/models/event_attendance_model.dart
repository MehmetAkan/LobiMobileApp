import 'package:lobi_application/data/models/event_attendance_status.dart';


class EventAttendanceModel {
  final String id;
  final String eventId;
  final String userId;
  final EventAttendanceStatus status;
  final DateTime joinedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const EventAttendanceModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    this.approvedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  /// Supabase'den gelen JSON'u model'e çevir
  factory EventAttendanceModel.fromJson(Map<String, dynamic> json) {
    return EventAttendanceModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      status: EventAttendanceStatus.fromDbValue(json['status'] as String?),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'status': status.dbValue,
      'joined_at': joinedAt.toIso8601String(),
      if (approvedAt != null) 'approved_at': approvedAt!.toIso8601String(),
      if (rejectedAt != null) 'rejected_at': rejectedAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
    };
  }

  /// Katılım iptal edildi mi?
  bool get isCancelled => cancelledAt != null;

  /// Katılım aktif mi? (iptal edilmemiş ve reddedilmemiş)
  bool get isActive => !isCancelled && status != EventAttendanceStatus.rejected;

  /// CopyWith
  EventAttendanceModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    EventAttendanceStatus? status,
    DateTime? joinedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return EventAttendanceModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  String toString() {
    return 'EventAttendanceModel(id: $id, eventId: $eventId, userId: $userId, status: ${status.dbValue})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventAttendanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}