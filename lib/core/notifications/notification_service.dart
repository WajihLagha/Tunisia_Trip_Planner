import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tunisian_trip_planner/core/notifications/notification_messages.dart';

/// A reusable notification service for scheduling re-engagement reminders.
///
/// Usage:
/// 1. Call [NotificationService.init] once during app startup (in main.dart).
/// 2. Call [NotificationService.scheduleReEngagement] every time the user opens
///    the app — it cancels previous reminders and reschedules fresh ones.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final Random _random = Random();

  // ── Reminder schedule (days after last app open) ──────────────────────────
  static const List<int> _reminderDaysAfterOpen = [2, 5, 10];

  // ── Notification channel config ───────────────────────────────────────────
  static const String _channelId = 'tuniways_reengagement';
  static const String _channelName = 'TuniWays Reminders';
  static const String _channelDesc =
      'Friendly reminders to come back and explore Tunisia.';

  // ── Base notification ID for re-engagement (avoids collision) ─────────────
  static const int _baseId = 9000;

  // ──────────────────────────────────────────────────────────────────────────
  //  INIT
  // ──────────────────────────────────────────────────────────────────────────

  /// Initialises timezone data, the plugin, and requests permissions.
  /// Call this once in `main()` **after** `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<void> init() async {
    // 1. Timezone setup
    tz.initializeTimeZones();

    // 2. Platform-specific init settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher', // default app icon
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 3. Request permission (Android 13+ / iOS)
    await _requestPermission();

    debugPrint('🔔 NotificationService initialised');
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  PERMISSION
  // ──────────────────────────────────────────────────────────────────────────

  static Future<void> _requestPermission() async {
    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  SCHEDULE RE-ENGAGEMENT
  // ──────────────────────────────────────────────────────────────────────────

  /// Cancels any previously scheduled re-engagement notifications and
  /// reschedules new ones for [_reminderDaysAfterOpen] days from now.
  ///
  /// Call this in `initState` of your root widget or on every app resume.
  static Future<void> scheduleReEngagement() async {
    // Cancel old ones first
    await cancelReEngagement();

    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < _reminderDaysAfterOpen.length; i++) {
      final days = _reminderDaysAfterOpen[i];
      final message = _pickRandomMessage();

      // Schedule at 10:00 AM on the target day for a natural feel
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + days,
        10, // hour
        0, // minute
      );

      await _plugin.zonedSchedule(
        _baseId + i,
        message.title,
        message.body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: const BigTextStyleInformation(''),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null, // one-shot, not repeating
      );

      debugPrint(
        '📅 Scheduled "${message.title}" for $scheduledDate (${days}d from now)',
      );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  CANCEL
  // ──────────────────────────────────────────────────────────────────────────

  /// Cancels all previously scheduled re-engagement notifications.
  static Future<void> cancelReEngagement() async {
    for (int i = 0; i < _reminderDaysAfterOpen.length; i++) {
      await _plugin.cancel(_baseId + i);
    }
    debugPrint('🗑️ Cancelled previous re-engagement notifications');
  }

  /// Cancels every notification managed by this plugin.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  /// Picks a random message from the pool so each notification feels fresh.
  static NotificationMessage _pickRandomMessage() {
    return NotificationMessages.all[
        _random.nextInt(NotificationMessages.all.length)];
  }

  /// Called when the user taps a notification. Add navigation logic here.
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // You can navigate to a specific screen here using a global navigator key
    // or by storing the payload and reading it on next app build.
  }
}
