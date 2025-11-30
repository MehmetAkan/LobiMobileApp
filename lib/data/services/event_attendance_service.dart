import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/event_attendance_model.dart';
import 'package:lobi_application/data/models/event_attendance_status.dart';
import 'package:lobi_application/data/services/verification_token_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// EventAttendanceService - Etkinlik katılım işlemleri
///
/// Supabase Tablo: event_participants
///
/// Kullanım:
/// ```dart
/// final service = EventAttendanceService();
///
/// // Durumu kontrol et
/// final status = await service.getAttendanceStatus(eventId);
///
/// // Etkinliğe katıl
/// await service.attendEvent(eventId, requiresApproval: false);
///
/// // Katılımdan ayrıl
/// await service.leaveEvent(eventId);
/// ```
class EventAttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'event_participants';

  /// Kullanıcının etkinliğe katılım durumunu kontrol et
  ///
  /// Returns:
  /// - notAttending: Katılmıyor
  /// - pending: Onay bekliyor
  /// - attending: Katılıyor (onaylandı)
  /// - rejected: Reddedildi
  Future<EventAttendanceStatus> getAttendanceStatus({
    required String eventId,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        AppLogger.warning('User not authenticated, returning notAttending');
        return EventAttendanceStatus.notAttending;
      }

      final response = await _supabase
          .from(_tableName)
          .select('status, cancelled_at')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      // Kayıt yoksa
      if (response == null) {
        return EventAttendanceStatus.notAttending;
      }

      // İptal edilmişse
      if (response['cancelled_at'] != null) {
        return EventAttendanceStatus.notAttending;
      }

      // Status'u parse et
      final status = EventAttendanceStatus.fromDbValue(
        response['status'] as String?,
      );

      return status;
    } catch (e, stackTrace) {
      AppLogger.error('getAttendanceStatus error', e, stackTrace);
      return EventAttendanceStatus.notAttending;
    }
  }

  /// Etkinliğe katıl
  ///
  /// requiresApproval:
  /// - false → status: 'attending' (direkt katılır)
  /// - true → status: 'pending' (organizatör onayı bekler)
  Future<EventAttendanceStatus> attendEvent({
    required String eventId,
    required bool requiresApproval,
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      throw AuthException('Kullanıcı oturumu bulunamadı');
    }

    try {
      final targetStatus = requiresApproval
          ? EventAttendanceStatus.pending
          : EventAttendanceStatus.attending;

      // Mevcut kaydı kontrol et
      final existing = await _supabase
          .from(_tableName)
          .select('id')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      final now = DateTime.now().toIso8601String();

      if (existing != null) {
        // Güncelle (iptal edilmişse yeniden aktif et)
        await _supabase
            .from(_tableName)
            .update({
              'status': targetStatus.dbValue,
              'approved_at': requiresApproval ? null : now,
              'rejected_at': null,
              'cancelled_at': null,
              'cancellation_reason': null,
            })
            .eq('event_id', eventId)
            .eq('user_id', userId);
      } else {
        // Yeni kayıt → Generate verification token
        final verificationCode = VerificationTokenService.generate();

        await _supabase.from(_tableName).insert({
          'event_id': eventId,
          'user_id': userId,
          'status': targetStatus.dbValue,
          'joined_at': now,
          'approved_at': requiresApproval ? null : now,
          'verification_code': verificationCode, // ✅ QR token
        });
      }

      AppLogger.success('Katılım başarılı: ${targetStatus.dbValue}');
      return targetStatus;
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in attendEvent', e);
      throw DatabaseException('Katılım işlemi başarısız: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('attendEvent error', e, stackTrace);
      rethrow;
    }
  }

  /// Etkinlikten ayrıl (soft delete)
  Future<void> leaveEvent({required String eventId, String? reason}) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      throw AuthException('Kullanıcı oturumu bulunamadı');
    }

    try {
      await _supabase
          .from(_tableName)
          .update({
            'cancelled_at': DateTime.now().toIso8601String(),
            'cancellation_reason': reason ?? 'Kullanıcı katılımı iptal etti',
          })
          .eq('event_id', eventId)
          .eq('user_id', userId);

      AppLogger.success('Etkinlikten ayrıldınız');
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in leaveEvent', e);
      throw DatabaseException('Ayrılma işlemi başarısız: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('leaveEvent error', e, stackTrace);
      rethrow;
    }
  }

  /// Katılımcı listesi (organizatör için)
  ///
  /// User bilgileriyle birlikte çekmek için iki ayrı query yapar ve merge eder
  Future<List<Map<String, dynamic>>> getAttendeesWithUserInfo({
    required String eventId,
    EventAttendanceStatus? filterStatus,
    bool includeCancelled = false,
  }) async {
    try {
      // 1. Event participants çek
      var query = _supabase.from(_tableName).select().eq('event_id', eventId);

      if (!includeCancelled) {
        query = query.isFilter('cancelled_at', null);
      }

      if (filterStatus != null) {
        query = query.eq('status', filterStatus.dbValue);
      }

      final participants = await query;

      if (participants.isEmpty) {
        return [];
      }

      // 2. User ID'leri topla
      final userIds = (participants as List)
          .map((p) => p['user_id'] as String)
          .toList();

      // 3. Profiles çek
      final profiles = await _supabase
          .from('profiles')
          .select('user_id, first_name, last_name, avatar_url')
          .inFilter('user_id', userIds);

      // 4. Merge et
      final profileMap = <String, Map<String, dynamic>>{};
      for (var profile in profiles as List) {
        profileMap[profile['user_id'] as String] =
            profile as Map<String, dynamic>;
      }

      // 5. Birleştir
      final result = <Map<String, dynamic>>[];
      for (var participant in participants) {
        final participantMap = Map<String, dynamic>.from(
          participant as Map<String, dynamic>,
        );
        final userId = participantMap['user_id'] as String;

        if (profileMap.containsKey(userId)) {
          participantMap['profiles'] = profileMap[userId];
        }

        result.add(participantMap);
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('getAttendeesWithUserInfo error', e, stackTrace);
      return [];
    }
  }

  /// Katılımcı listesi (organizatör için) - Model olarak
  Future<List<EventAttendanceModel>> getAttendees({
    required String eventId,
    EventAttendanceStatus? filterStatus,
    bool includeCancelled = false,
  }) async {
    try {
      var query = _supabase.from(_tableName).select().eq('event_id', eventId);

      if (!includeCancelled) {
        query = query.isFilter('cancelled_at', null);
      }

      if (filterStatus != null) {
        query = query.eq('status', filterStatus.dbValue);
      }

      final response = await query;

      final attendances = (response as List)
          .map(
            (json) =>
                EventAttendanceModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return attendances;
    } catch (e, stackTrace) {
      AppLogger.error('getAttendees error', e, stackTrace);
      return [];
    }
  }

  /// Katılımcı sayısı
  Future<int> getAttendeeCount({
    required String eventId,
    EventAttendanceStatus? filterStatus,
    bool includeCancelled = false,
  }) async {
    final attendees = await getAttendees(
      eventId: eventId,
      filterStatus: filterStatus,
      includeCancelled: includeCancelled,
    );

    return attendees.length;
  }

  /// Organizatör: Katılımı onayla
  Future<void> approveAttendance({
    required String eventId,
    required String userId,
  }) async {
    try {
      // Update attendance status
      await _supabase
          .from(_tableName)
          .update({
            'status': EventAttendanceStatus.attending.dbValue,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq('event_id', eventId)
          .eq('user_id', userId);

      AppLogger.success('Katılım onaylandı');

      // Get event details for notification
      final eventResponse = await _supabase
          .from('events')
          .select('title, cover_image_url')
          .eq('id', eventId)
          .single();

      final eventTitle = eventResponse['title'] as String;
      final eventImage = eventResponse['cover_image_url'] as String?;

      // Create notification for approved user
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'event_id': eventId,
        'type': 'attendance_approved',
        'title': 'Katılım Talebiniz Onaylandı! 🎉',
        'body': '"$eventTitle" etkinliğine katılım talebiniz onaylandı.',
        'is_read': false,
        'data': {'event_id': eventId, 'event_image_url': eventImage},
      });

      AppLogger.info('✅ Onay bildirimi gönderildi: $userId');
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in approveAttendance', e);
      throw DatabaseException('Onaylama başarısız: ${e.message}');
    }
  }

  /// Organizatör: Katılımı reddet
  Future<void> rejectAttendance({
    required String eventId,
    required String userId,
    String? reason,
  }) async {
    try {
      // Update attendance status
      await _supabase
          .from(_tableName)
          .update({
            'status': EventAttendanceStatus.rejected.dbValue,
            'rejected_at': DateTime.now().toIso8601String(),
            'cancellation_reason': reason,
          })
          .eq('event_id', eventId)
          .eq('user_id', userId);

      AppLogger.success('Katılım reddedildi');

      // Get event details for notification
      final eventResponse = await _supabase
          .from('events')
          .select('title, cover_image_url')
          .eq('id', eventId)
          .single();

      final eventTitle = eventResponse['title'] as String;
      final eventImage = eventResponse['cover_image_url'] as String?;

      // Create notification for rejected user
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'event_id': eventId,
        'type': 'event_rejected',
        'title': 'Katılım Talebin Reddedildi',
        'body':
            '"$eventTitle" etkinliğine katılım talebin organizatör tarafından reddedildi.',
        'is_read': false,
        'data': {
          'event_id': eventId,
          'status': 'rejected',
          'event_image_url': eventImage,
        },
      });

      AppLogger.info('✅ Red bildirimi gönderildi: $userId');
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in rejectAttendance', e);
      throw DatabaseException('Reddetme başarısız: ${e.message}');
    }
  }

  /// Get all guests for an event (with profiles) - GUEST LIST
  Future<List<Map<String, dynamic>>> getEventGuests(String eventId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            profiles!inner(first_name, last_name, username, avatar_url)
          ''')
          .eq('event_id', eventId)
          .order('joined_at', ascending: false);

      AppLogger.success('Misafir listesi alındı: ${(response as List).length}');
      return (response as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in getEventGuests', e);
      throw DatabaseException('Misafir listesi alınamadı: ${e.message}');
    }
  }

  /// Update attendance status (mark as attended/did_not_attend)
  Future<void> updateAttendanceStatus({
    required String attendanceId,
    required EventAttendanceStatus newStatus,
  }) async {
    try {
      final updates = <String, dynamic>{'status': newStatus.dbValue};

      // Set attended_at if marking as attended
      if (newStatus == EventAttendanceStatus.attended) {
        updates['attended_at'] = DateTime.now().toIso8601String();
      }

      await _supabase.from(_tableName).update(updates).eq('id', attendanceId);

      AppLogger.success(
        'Kat\u0131l\u0131m durumu güncellendi: ${newStatus.dbValue}',
      );
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in updateAttendanceStatus', e);
      throw DatabaseException('Durum güncellenemedi: ${e.message}');
    }
  }

  /// Verify QR code and mark as attended
  ///
  /// Returns user profile data on success
  Future<Map<String, dynamic>> verifyCheckIn({
    required String attendanceId,
    required String verificationCode,
    required String eventId,
  }) async {
    try {
      // 1. Fetch attendance record
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', attendanceId)
          .single();

      final attendance = EventAttendanceModel.fromJson(response);

      // 2. Validate event match
      if (attendance.eventId != eventId) {
        throw ValidationException('Bu QR kod bu etkinlik için geçerli değil');
      }

      // 3. Validate verification code
      if (attendance.verificationCode != verificationCode) {
        throw ValidationException('Geçersiz doğrulama kodu');
      }

      // 4. Check if already attended
      if (attendance.status == EventAttendanceStatus.attended) {
        throw ValidationException(
          'Bu kullanıcı zaten katıldı olarak işaretlendi',
        );
      }

      // 5. Check if status is attending
      if (attendance.status != EventAttendanceStatus.attending) {
        throw ValidationException(
          'Bu kullanıcının katılım durumu uygun değil (${attendance.status.displayText})',
        );
      }

      // 6. Update to attended
      await _supabase
          .from(_tableName)
          .update({
            'status': EventAttendanceStatus.attended.dbValue,
            'attended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', attendanceId);

      // 7. Get user profile for feedback
      final profileResponse = await _supabase
          .from('profiles')
          .select('first_name, last_name, avatar_url')
          .eq('user_id', attendance.userId)
          .single();

      final firstName = profileResponse['first_name'] as String? ?? '';
      final lastName = profileResponse['last_name'] as String? ?? '';
      final fullName = '$firstName $lastName'.trim();

      AppLogger.success('Check-in successful: $fullName');

      return {
        'success': true,
        'full_name': fullName.isNotEmpty ? fullName : 'İsimsiz',
        'avatar_url': profileResponse['avatar_url'] as String?,
        'attendance_id': attendanceId,
      };
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in verifyCheckIn', e);
      throw DatabaseException('Doğrulama başarısız: ${e.message}');
    }
  }
}
