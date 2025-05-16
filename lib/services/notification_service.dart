import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/env_config.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
  await NotificationService.instance.showNotification(
    title: message.notification?.title ?? 'New Message',
    body: message.notification?.body ?? '',
    payload: json.encode(message.data),
    imageUrl: message.notification?.android?.imageUrl ?? message.data['image'],
  );
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  String? _pendingInitialUrl;

  // Callback for handling URL navigation
  Function(String)? onNotificationUrlReceived;

  Future<void> init() async {
    if (_initialized) return;

    if (!EnvConfig.instance.isPushEnabled) {
      debugPrint('Push notifications are disabled in configuration');
      return;
    }

    _initialized = true;

    // Initialize Firebase Messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Subscribe to topics
    await _subscribeToTopics();

    // Request notification permissions
    await _requestNotificationPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set up notification handlers
    _setupNotificationHandlers();

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          'App opened from terminated state: ${initialMessage.notification?.title}');
      _handleNotificationMessage(initialMessage);
    }

    // Get and save FCM token
    await _getFCMToken();
  }

  Future<void> _subscribeToTopics() async {
    await _firebaseMessaging.subscribeToTopic('all_users');
    if (Platform.isAndroid) {
      await _firebaseMessaging.subscribeToTopic('android_users');
    } else if (Platform.isIOS) {
      await _firebaseMessaging.subscribeToTopic('ios_users');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
      );

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        debugPrint('Received iOS local notification: $title');
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
        _handleNotificationPayload(details.payload);
      },
    );
  }

  void _setupNotificationHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Received foreground message: ${message.notification?.title}');
      await _handleNotificationMessage(message);
    });

    // Handle when app is in background and user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'App opened from background state: ${message.notification?.title}');
      _handleNotificationMessage(message);
    });
  }

  Future<void> _getFCMToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      final directory = Directory.current;
      final file = File('${directory.path}/fcm_token.txt');
      await file.writeAsString(token);
      debugPrint('FCM token saved to: ${file.path}');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    AndroidNotificationDetails androidDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/notif_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        androidDetails = AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            largeIcon: FilePathAndroidBitmap(filePath),
            contentTitle: '<b>$title</b>',
            summaryText: body,
            htmlFormatContentTitle: true,
            htmlFormatSummaryText: true,
          ),
        );
      } catch (e) {
        debugPrint('Failed to load notification image: $e');
        androidDetails = _getDefaultAndroidDetails();
      }
    } else {
      androidDetails = _getDefaultAndroidDetails();
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  AndroidNotificationDetails _getDefaultAndroidDetails() {
    return const AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
  }

  Future<void> _handleNotificationMessage(RemoteMessage message) async {
    // Show the notification
    await showNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      payload: json.encode(message.data),
      imageUrl:
          message.notification?.android?.imageUrl ?? message.data['image'],
    );

    // Handle URL navigation
    final internalUrl = message.data['url'];
    if (internalUrl != null && internalUrl.isNotEmpty) {
      if (onNotificationUrlReceived != null) {
        onNotificationUrlReceived!(internalUrl);
      } else {
        _pendingInitialUrl = internalUrl;
      }
    }
  }

  void _handleNotificationPayload(String? payload) {
    if (payload != null) {
      try {
        final data = json.decode(payload);
        final url = data['url'];
        if (url != null &&
            url.isNotEmpty &&
            onNotificationUrlReceived != null) {
          onNotificationUrlReceived!(url);
        }
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  String? getPendingInitialUrl() {
    final url = _pendingInitialUrl;
    _pendingInitialUrl = null;
    return url;
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
