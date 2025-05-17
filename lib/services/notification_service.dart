import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import 'notification/firebase_messaging_service.dart';
import 'notification/local_notification_service.dart';
import 'error_handling_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;
  bool _initialized = false;

  // Callback for handling URL navigation
  Function(String)? onNotificationUrlReceived;

  Future<void> init() async {
    if (_initialized) return;

    if (!EnvConfig.instance.isPushEnabled) {
      debugPrint('Push notifications are disabled in configuration');
      return;
    }

    await _errorHandler.wrapError('NotificationService.init', () async {
      _initialized = true;

      // Initialize local notifications
      await LocalNotificationService.instance.initialize(
        onNotificationTapped: _handleNotificationTapped,
      );

      // Initialize Firebase messaging
      await FirebaseMessagingService.instance.initialize();
      FirebaseMessagingService.instance.onNotificationUrlReceived =
          onNotificationUrlReceived;
    });
  }

  void _handleNotificationTapped(String? payload) {
    if (payload != null) {
      try {
        final data = Map<String, dynamic>.from(
          Map.castFrom(json.decode(payload)),
        );
        final url = data['url'];
        if (url != null &&
            url.isNotEmpty &&
            onNotificationUrlReceived != null) {
          onNotificationUrlReceived!(url);
        }
      } catch (e, stackTrace) {
        _errorHandler.handleError(
          'NotificationService._handleNotificationTapped',
          e,
          stackTrace,
        );
      }
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    await LocalNotificationService.instance.showNotification(
      title: title,
      body: body,
      payload: payload,
      imageUrl: imageUrl,
    );
  }
}
