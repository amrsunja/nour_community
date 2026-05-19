import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


/// Notification ID partitioning. Each feature owns a contiguous range so
/// re-scheduling can `cancel` the whole range without touching others.
abstract class NotificationIds {
  // Daily ayah — single repeating notification.
  static const int dailyAyah = 1000;

  // Prayers: 2000..2999 → 7 days × 5 prayers = 35 IDs used.
  // id = prayerBase + (dayOffset * 5) + slotIndex(0..4)
  static const int prayersBase = 2000;
  static const int prayersEnd = 2999;
  static const int prayersDaysAhead = 7;

  // Morning adhkar: 3000..3099 — one per day for [prayersDaysAhead] days.
  static const int morningAdhkarBase = 3000;
  static const int morningAdhkarEnd = 3099;

  // Evening adhkar: 4000..4099
  static const int eveningAdhkarBase = 4000;
  static const int eveningAdhkarEnd = 4099;
}

final notificationsServicesProvider = Provider(
	(ref) => NotificationsServices()
);

class NotificationsServices {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<bool> requestPermissions() async {
    final response = await Permission.notification.request();

    return response.isGranted;
  }

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) return ;

    // 1. Initialize the timezone database
    tz.initializeTimeZones();

    try {
      // Correctly accessing the identifier from the object
      // 2. Get the device's specific timezone string (e.g., "Africa/Cairo" or "Europe/London")
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      // 3. Set the local location so tz.local works
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      // Fallback if the platform fails to return a timezone
      tz.setLocalLocation(tz.getLocation('UTC'));
    }



    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings
    );

    await notificationPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_chanel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  void showSimpleNotification() async {
    /*
    await notificationPlugin.show(
      0,
      'Hello from Nour!',
      'This is a simple notification.',
      notificationDetails(),
    );
    */
  }

  // Helper to get the next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    int minute = 0,
    required int atMinute,
  }) async {
    await notificationPlugin.zonedSchedule(
      id, // Unique ID
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
    );
  }

  /// Schedule a one-time notification at an exact instant (already in `tz.local`).
  /// Used for prayers / adhkar where each day's time differs.
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
  }) async {
    if (!_isInitialized) await initialize();
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      when,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule a daily-repeating notification at HH:mm in local time.
  Future<void> scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    int minute = 0,
  }) async {
    if (!_isInitialized) await initialize();
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> removeScheduledNotifications(int id) async {
    await notificationPlugin.cancel(id);
  }

  /// Cancel every scheduled notification whose id falls inside [start, end].
  Future<void> cancelRange(int start, int end) async {
    final pending = await notificationPlugin.pendingNotificationRequests();
    for (final n in pending) {
      if (n.id >= start && n.id <= end) {
        await notificationPlugin.cancel(n.id);
      }
    }
  }

  Future<void> removeAllNotifications() async {
    await notificationPlugin.cancelAll();
  }
}
