import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/talker/talker.dart';

import 'notifications_services.dart';

/// Background handler: the OS renders `notification` payloads itself; we only
/// log. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> nourFirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Intentionally empty — data-only messages are not used.
}

final pushNotificationsServicesProvider = Provider(
  (ref) => PushNotificationsServices(local: ref.read(notificationsServicesProvider)),
);

/// Firebase Cloud Messaging wrapper (devis Poste 1). Lives next to the local
/// scheduler ([NotificationsServices]) which stays the owner of prayer /
/// adhkar reminders.
///
/// Wiring: `initialize()` once at startup (after Firebase.initializeApp),
/// `currentToken()` whenever the session changes so the token is registered
/// server-side, `onOpened` for deep links.
class PushNotificationsServices {
  PushNotificationsServices({required this.local});

  final NotificationsServices local;

  /// Android channel used by FCM for mosque pushes (matches send-push).
  static const String mosquesChannelId = 'nour_mosques';
  static const String mosquesChannelName = 'Mosque updates';

  final _openedController = StreamController<Map<String, dynamic>>.broadcast();
  final _tokenController = StreamController<String>.broadcast();

  /// Data payload of a tapped notification (`link`, `logId`, `kind`…).
  Stream<Map<String, dynamic>> get onOpened => _openedController.stream;

  /// Emits whenever FCM rotates the device token.
  Stream<String> get onTokenRefresh => _tokenController.stream;

  bool _initialized = false;
  Map<String, dynamic>? _pendingInitial;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(nourFirebaseMessagingBackgroundHandler);

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (Platform.isAndroid) {
        await local.notificationPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(const AndroidNotificationChannel(
              mosquesChannelId,
              mosquesChannelName,
              description: 'News, events and campaigns from the mosques you follow',
              importance: Importance.high,
            ));
      }

      // Foreground: Android does not display FCM notifications while the app
      // is in front — mirror them through the local plugin.
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _openedController.add(m.data));
      messaging.onTokenRefresh.listen(_tokenController.add);

      final initial = await messaging.getInitialMessage();
      if (initial != null) _pendingInitial = initial.data;
    } catch (e, st) {
      talker.handle(e, st, 'push init');
      FirebaseCrashlytics.instance.recordError(e, st, fatal: false);
    }
  }

  /// The notification that launched the app (cold start), consumed once.
  Map<String, dynamic>? takeInitialMessage() {
    final m = _pendingInitial;
    _pendingInitial = null;
    return m;
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e, st) {
      talker.handle(e, st, 'push permission');
      return false;
    }
  }

  Future<String?> currentToken() async {
    try {
      if (Platform.isIOS) {
        // APNs token must exist before FCM can mint its token.
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns == null) return null;
      }
      return await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      talker.handle(e, st, 'push token');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e, st) {
      talker.handle(e, st, 'push delete token');
    }
  }

  int _foregroundId = NotificationIds.pushBase;

  Future<void> _onForeground(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    if (!Platform.isAndroid) return; // iOS shows it via presentation options.
    try {
      if (!local.isInitialized) await local.initialize();
      _foregroundId = _foregroundId >= NotificationIds.pushEnd ? NotificationIds.pushBase : _foregroundId + 1;
      await local.notificationPlugin.show(
        _foregroundId,
        n.title,
        n.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            mosquesChannelId,
            mosquesChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data['link'] as String?,
      );
    } catch (e, st) {
      talker.handle(e, st, 'push foreground');
    }
  }
}
