import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../config/env_config.dart';
import '../error_handling_service.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
  await LocalNotificationService.instance.showNotification(
    title: message.notification?.title ?? 'New Message',
    body: message.notification?.body ?? '',
    payload: json.encode(message.data),
    imageUrl: message.notification?.android?.imageUrl ?? message.data['image'],
  );
}

class FirebaseMessagingService {
  static final FirebaseMessagingService instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;
  bool _initialized = false;
  String? _pendingInitialUrl;

  // Callback for handling URL navigation
  Function(String)? onNotificationUrlReceived;

  Future<void> initialize() async {
    if (_initialized || !EnvConfig.instance.isPushEnabled) {
      debugPrint(
          'Firebase Messaging ${_initialized ? 'already initialized' : 'disabled in configuration'}');
      return;
    }

    await _errorHandler.wrapError('FirebaseMessaging.initialize', () async {
      _initialized = true;

      // Initialize background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Subscribe to topics
      await _subscribeToTopics();

      // Request permissions
      await _requestNotificationPermissions();

      // Set up handlers
      _setupNotificationHandlers();

      // Check initial message
      await _checkInitialMessage();

      // Get and save FCM token
      await _getFCMToken();
    });
  }

  Future<void> _subscribeToTopics() async {
    await _errorHandler.wrapError('FirebaseMessaging._subscribeToTopics',
        () async {
      await _firebaseMessaging.subscribeToTopic('all_users');
      if (Platform.isAndroid) {
        await _firebaseMessaging.subscribeToTopic('android_users');
      } else if (Platform.isIOS) {
        await _firebaseMessaging.subscribeToTopic('ios_users');
      }
    });
  }

  Future<void> _requestNotificationPermissions() async {
    await _errorHandler.wrapError('FirebaseMessaging._requestPermissions',
        () async {
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
    });
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

  Future<void> _checkInitialMessage() async {
    await _errorHandler.wrapError('FirebaseMessaging._checkInitialMessage',
        () async {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            'App opened from terminated state: ${initialMessage.notification?.title}');
        _handleNotificationMessage(initialMessage);
      }
    });
  }

  Future<void> _getFCMToken() async {
    await _errorHandler.wrapError('FirebaseMessaging._getFCMToken', () async {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        final directory = Directory.current;
        final file = File('${directory.path}/fcm_token.txt');
        await file.writeAsString(token);
        debugPrint('FCM token saved to: ${file.path}');
      }
    });
  }

  Future<void> _handleNotificationMessage(RemoteMessage message) async {
    await _errorHandler.wrapError('FirebaseMessaging._handleMessage', () async {
      // Show the notification
      await LocalNotificationService.instance.showNotification(
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
    });
  }

  String? getPendingUrl() {
    final url = _pendingInitialUrl;
    _pendingInitialUrl = null;
    return url;
  }
}
