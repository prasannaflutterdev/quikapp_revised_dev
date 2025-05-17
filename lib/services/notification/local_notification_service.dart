import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../config/env_config.dart';
import '../error_handling_service.dart';

class LocalNotificationService {
  static final LocalNotificationService instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  Future<void> initialize({
    Function(String?)? onNotificationTapped,
  }) async {
    await _errorHandler.wrapError('LocalNotification.initialize', () async {
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
          if (onNotificationTapped != null) {
            onNotificationTapped(details.payload);
          }
        },
      );
    });
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    await _errorHandler.wrapError('LocalNotification.showNotification',
        () async {
      AndroidNotificationDetails androidDetails;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final imagePath = await _downloadAndSaveImage(imageUrl);
        androidDetails = await _createBigPictureStyle(title, body, imagePath);
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
    });
  }

  Future<String?> _downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/notif_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e, stackTrace) {
      _errorHandler.handleError(
          'LocalNotification._downloadAndSaveImage', e, stackTrace);
      return null;
    }
  }

  Future<AndroidNotificationDetails> _createBigPictureStyle(
    String title,
    String body,
    String? imagePath,
  ) async {
    if (imagePath == null) return _getDefaultAndroidDetails();

    return AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(imagePath),
        largeIcon: FilePathAndroidBitmap(imagePath),
        contentTitle: '<b>$title</b>',
        summaryText: body,
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true,
      ),
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
}
