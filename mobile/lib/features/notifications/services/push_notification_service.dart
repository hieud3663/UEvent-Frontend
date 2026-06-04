import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> ueventFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // Firebase chưa được cấu hình trên môi trường hiện tại.
  }
}

class PushNotificationService {
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'uevent_notifications',
        'Thông báo UEvent',
        description: 'Thông báo mới từ hệ thống UEvent.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _localNotifications;
  FirebaseMessaging? _messaging;
  final StreamController<String?> _localNotificationTapController =
      StreamController<String?>.broadcast();

  bool _initialized = false;
  bool _available = false;

  PushNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  FirebaseMessaging get _messagingInstance =>
      _messaging ??= FirebaseMessaging.instance;

  Future<bool> initialize() async {
    if (_initialized) return _available;

    _initialized = true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      FirebaseMessaging.onBackgroundMessage(
        ueventFirebaseMessagingBackgroundHandler,
      );
      await _initializeLocalNotifications();
      _available = true;
      debugPrint('Firebase Messaging đã sẵn sàng.');
      return true;
    } catch (error) {
      debugPrint('Không thể khởi tạo Firebase Messaging: $error');
      _available = false;
      return false;
    }
  }

  Future<String?> requestToken() async {
    if (!await initialize()) return null;

    await _requestLocalNotificationPermission();
    final messaging = _messagingInstance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      'Trạng thái quyền thông báo: ${settings.authorizationStatus.name}',
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    final token = await messaging.getToken();
    debugPrint(
      token == null || token.isEmpty
          ? 'Không lấy được FCM token.'
          : 'Đã lấy được FCM token.',
    );
    return token;
  }

  Future<void> showForegroundNotification(RemoteMessage message) async {
    if (!await initialize()) return;

    final title =
        message.notification?.title ?? message.data['title'] ?? 'Thông báo mới';
    final body =
        message.notification?.body ??
        message.data['body'] ??
        'Bạn có thông báo mới từ UEvent.';

    await _localNotifications.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'uevent_notifications',
          'Thông báo UEvent',
          channelDescription: 'Thông báo mới từ hệ thống UEvent.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _localNotificationTapController.add(response.payload);
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _requestLocalNotificationPermission() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Stream<String> get onTokenRefresh => _messagingInstance.onTokenRefresh;

  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onNotificationOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Stream<String?> get onLocalNotificationTap =>
      _localNotificationTapController.stream;

  Future<RemoteMessage?> getInitialMessage() {
    return _messagingInstance.getInitialMessage();
  }

  Future<String?> getInitialLocalNotificationPayload() async {
    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }
}
