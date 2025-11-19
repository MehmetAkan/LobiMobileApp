import 'package:lobi_application/core/errors/app_exception.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/data/models/event_attendance_model.dart';
import 'package:lobi_application/data/models/event_attendance_status.dart';
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
        // Yeni kayıt
        await _supabase.from(_tableName).insert({
          'event_id': eventId,
          'user_id': userId,
          'status': targetStatus.dbValue,
          'joined_at': now,
          'approved_at': requiresApproval ? null : now,
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
  Future<void> leaveEvent({
    required String eventId,
    String? reason,
  }) async {
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
  Future<List<EventAttendanceModel>> getAttendees({
    required String eventId,
    EventAttendanceStatus? filterStatus,
    bool includeCancelled = false,
  }) async {
    try {
      var query = _supabase
          .from(_tableName)
          .select()
          .eq('event_id', eventId);

      if (!includeCancelled) {
        query = query.isFilter('cancelled_at', null);
      }

      if (filterStatus != null) {
        query = query.eq('status', filterStatus.dbValue);
      }

      final response = await query;

      final attendances = (response as List)
          .map((json) => EventAttendanceModel.fromJson(json as Map<String, dynamic>))
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
      await _supabase
          .from(_tableName)
          .update({
            'status': EventAttendanceStatus.attending.dbValue,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq('event_id', eventId)
          .eq('user_id', userId);

      AppLogger.success('Katılım onaylandı');
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
    } on PostgrestException catch (e) {
      AppLogger.error('Supabase error in rejectAttendance', e);
      throw DatabaseException('Reddetme başarısız: ${e.message}');
    }
  }
}