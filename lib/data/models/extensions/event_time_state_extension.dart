import 'package:flutter/foundation.dart';
import 'package:lobi_application/data/models/event_model.dart';

/// Event duration configuration constants
class EventDurationConfig {
  /// Default event duration when end_date is null
  static const Duration defaultEventDuration = Duration(hours: 3);

  /// Check-in window opens this duration before event start
  static const Duration checkinWindowBeforeStart = Duration(hours: 3);
}

/// Event time state based on server time
enum EventTimeState {
  /// Before check-in window (3+ hours before event start)
  /// - Guest list & check-in: HIDDEN
  /// - Edit details: VISIBLE
  beforeCheckinWindow,

  /// Check-in active (3 hours before start - event end)
  /// - Guest list & check-in: VISIBLE
  /// - Edit details: VISIBLE
  checkinActive,

  /// Event has ended
  /// - Guest list: VISIBLE (read-only)
  /// - Check-in: HIDDEN
  /// - Edit details: HIDDEN
  ended,
}

/// Extension for event time state calculations
/// SECURITY: Uses SERVER time (not device time) to prevent manipulation
extension EventTimeStateExtension on EventModel {
  /// Gets current event state based on SERVER time
  ///
  /// Falls back to device UTC time if server time unavailable
  /// (this should never happen in production)
  EventTimeState get timeState {
    final now = serverCurrentTime ?? DateTime.now().toUtc();

    // Log warning if server time unavailable
    if (serverCurrentTime == null && kDebugMode) {
      debugPrint(
        '⚠️ WARNING: Server time unavailable for event $id, using device UTC',
      );
    }

    return _calculateTimeState(now);
  }

  /// Calculate time state with explicit reference time
  /// Exposed for testing purposes
  EventTimeState _calculateTimeState(DateTime referenceTime) {
    // Check-in opens 3 hours before event
    final checkinStartTime = date.subtract(
      EventDurationConfig.checkinWindowBeforeStart,
    );

    // Event end time (use endDate, fallback to startDate if null)
    // Since users are required to provide end_date, this fallback should rarely happen
    final eventEndTime = endDate ?? date;

    if (referenceTime.isBefore(checkinStartTime)) {
      return EventTimeState.beforeCheckinWindow;
    } else if (referenceTime.isBefore(eventEndTime)) {
      return EventTimeState.checkinActive;
    } else {
      return EventTimeState.ended;
    }
  }

  // ========================================
  // UI Helper Getters
  // ========================================

  /// Can edit event details (title, description, etc.)
  bool get canEditEventDetails => timeState != EventTimeState.ended;

  /// Can manage access settings (public/private, approval)
  bool get canManageAccess => timeState != EventTimeState.ended;

  /// Can cancel the event
  bool get canCancelEvent => timeState != EventTimeState.ended;

  /// Can view guest list (visible after check-in window opens)
  bool get canAccessGuestList =>
      timeState != EventTimeState.beforeCheckinWindow;

  /// Can perform check-in (QR code, manual)
  bool get canPerformCheckin => timeState == EventTimeState.checkinActive;

  // ========================================
  // Display Helpers
  // ========================================

  /// Human-readable time state
  String get timeStateDisplayText {
    switch (timeState) {
      case EventTimeState.beforeCheckinWindow:
        return 'Etkinlik Başlamadı';
      case EventTimeState.checkinActive:
        return 'Etkinlik Devam Ediyor';
      case EventTimeState.ended:
        return 'Etkinlik Sona Erdi';
    }
  }
}
