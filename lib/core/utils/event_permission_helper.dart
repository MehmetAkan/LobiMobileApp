import 'package:lobi_application/data/models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventPermissionHelper {
  EventPermissionHelper._(); 

  static String? _cachedUserId;
  static DateTime? _cacheTime;
  static const _cacheDuration = Duration(seconds: 30);

  static String? get _currentUserId {
    final now = DateTime.now();
    
    if (_cachedUserId != null && 
        _cacheTime != null && 
        now.difference(_cacheTime!) < _cacheDuration) {
      return _cachedUserId;
    }
    
    _cachedUserId = Supabase.instance.client.auth.currentUser?.id;
    _cacheTime = now;
    
    return _cachedUserId;
  }

  static void clearCache() {
    _cachedUserId = null;
    _cacheTime = null;
  }

  static bool isOrganizer(EventModel event) {
    if (_currentUserId == null) return false;
    if (event.organizerId == null) return false;
    
    return event.organizerId == _currentUserId;
  }

  static bool canEdit(EventModel event) {
    return isOrganizer(event);
  }

  static bool canDelete(EventModel event) {
    return isOrganizer(event);
  }

  static bool canSendAnnouncement(EventModel event) {
    return isOrganizer(event);
  }

  static bool canViewAttendees(EventModel event) {
    return isOrganizer(event);
  }

  static bool canViewStatistics(EventModel event) {
    return isOrganizer(event);
  }

  static DetailButtonType getDetailButtonType(EventModel event) {
    return isOrganizer(event) 
        ? DetailButtonType.organizer 
        : DetailButtonType.attendee;
  }
}

enum DetailButtonType {
  organizer,
  
  attendee,
}