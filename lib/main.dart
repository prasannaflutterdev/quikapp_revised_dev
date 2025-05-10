import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/env_config.dart';
import '../module/myapp.dart';
import '../services/notification_service.dart';
import '../utils/menu_parser.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLocalNotifications();

  if (pushNotify) {
    await initializeFirebaseMessaging();
  } else {
    debugPrint("🚫 Firebase not initialized (pushNotify: $pushNotify, isWeb: $kIsWeb)");
  }

  if (webUrl.isEmpty) {
    debugPrint("❗ Missing WEB_URL environment variable.");
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text("WEB_URL not configured.")),
      ),
    ));
    return;
  }
    debugPrint("""
      🛠 Runtime Config:
      - pushNotify: $pushNotify
      - webUrl: $webUrl
      - isSplash: $isSplashEnabled,
      - splashLogo: $splashUrl,
      - splashBg: $splashBgUrl,
      - splashDuration: $splashDuration,
      - splashAnimation: $splashAnimation,
      - taglineColor: $splashTaglineColor,
      - spbgColor: $splashBgColor,
      - isBottomMenu: $isBottomMenu,
      - bottomMenuItems: ${parseBottomMenuItems(bottomMenuRaw)},
      - isDeeplink: $isDeepLink,
      - backgroundColor: $bottomMenuBgColor,
      - activeTabColor: $bottomMenuActiveTabColor,
      - textColor: $bottomMenuTextColor,
      - iconColor: $bottomMenuIconColor,
      - iconPosition: $bottomMenuIconPosition,
      - Permissions:
        - Camera: $isCameraEnabled
        - Location: $isLocationEnabled
        - Mic: $isMicEnabled
        - Notification: $isNotificationEnabled
        - Contact: $isContactEnabled
      """);

  runApp(MyApp(
    webUrl: webUrl,

    isSplash: isSplashEnabled,
    splashLogo: splashUrl,
    splashBg: splashBgUrl,
    splashDuration: splashDuration,
    splashAnimation: splashAnimation,
    taglineColor: splashTaglineColor,
    spbgColor: splashBgColor,
    isBottomMenu: isBottomMenu,
    bottomMenuItems: parseBottomMenuItems(bottomMenuRaw),
    isDeeplink: isDeepLink,
    backgroundColor: bottomMenuBgColor,
    activeTabColor: bottomMenuActiveTabColor,
    textColor: bottomMenuTextColor,
    iconColor: bottomMenuIconColor,
    iconPosition: bottomMenuIconPosition,
    isLoadIndicator: isLoadIndicator,


  ));
}

// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'module/myapp.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
// bool? hasInternet;
//
// const bool pushNotify = bool.fromEnvironment('PUSH_NOTIFY', defaultValue: false);
// const bool isBottomMenu = bool.fromEnvironment('IS_BOTTOMMENU', defaultValue: false);
// const String bottomMenuRaw = String.fromEnvironment('BOTTOMMENU_ITEMS', defaultValue: '[]');
//
// List<Map<String, dynamic>> parseBottomMenu(String raw) {
//   try {
//     final decoded = jsonDecode(raw) as List;
//     return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
//   } catch (e) {
//     debugPrint("⚠️ Failed to parse BOTTOMMENU_ITEMS: $e");
//     return [];
//   }
// }
//
// final List<Map<String, dynamic>> bottomMenuItems = parseBottomMenu(bottomMenuRaw);
//
// // final List<Map<String, dynamic>> bottomMenuItems =
// // (jsonDecode(bottomMenuRaw) as List)
// //     .map((e) => Map<String, dynamic>.from(e))
// //     .toList();
// const bool isCameraEnabled = bool.fromEnvironment('IS_CAMERA', defaultValue: false);
// const isLocationEnabled = bool.fromEnvironment('IS_LOCATION', defaultValue: false);
// const isBiometricEnabled = bool.fromEnvironment('IS_BIOMETRIC', defaultValue: false);
// const isMicEnabled = bool.fromEnvironment('IS_MIC', defaultValue: false);
// const isContactEnabled = bool.fromEnvironment('IS_CONTACT', defaultValue: false);
// const isCalendarEnabled = bool.fromEnvironment('IS_CALENDAR', defaultValue: false);
// const isNotificationEnabled = bool.fromEnvironment('IS_NOTIFICATION', defaultValue: false);
// const isStorageEnabled = bool.fromEnvironment('IS_STORAGE', defaultValue: false);
// const splashDuration = int.fromEnvironment('SPLASH_DURATION', defaultValue: 3);
// const isSplashEnabled = bool.fromEnvironment('IS_SPLASH', defaultValue: false);
// const String splashUrl = String.fromEnvironment('SPLASH', defaultValue: '');
// const String splashBgUrl = String.fromEnvironment('SPLASH_BG', defaultValue: '');
// const String splashTagline = String.fromEnvironment('SPLASH_TAGLINE', defaultValue: '');
// const String splashAnimation = String.fromEnvironment('SPLASH_ANIMATION', defaultValue: 'zoom');
// const bool isPullDown = bool.fromEnvironment('IS_PULLDOWN', defaultValue: false);
// const String webUrl = String.fromEnvironment('WEB_URL');
//
// WebViewEnvironment? webViewEnvironment;
//
// Future<FirebaseOptions> loadFirebaseOptionsFromJson() async {
//   final jsonStr = await rootBundle.loadString('assets/google-services.json');
//   final jsonMap = json.decode(jsonStr);
//
//   final client = jsonMap['client'][0];
//   return FirebaseOptions(
//     apiKey: client['api_key'][0]['current_key'],
//     appId: client['client_info']['mobilesdk_app_id'],
//     messagingSenderId: jsonMap['project_info']['project_number'],
//     projectId: jsonMap['project_info']['project_id'],
//     storageBucket: jsonMap['project_info']['storage_bucket'],
//   );
// }
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint("🔔 Background message: ${message.messageId}");
// }
// void main() async {
//
//   WidgetsFlutterBinding.ensureInitialized();
//
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//
//   const InitializationSettings initializationSettings =
//   InitializationSettings(android: initializationSettingsAndroid);
//
//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: (NotificationResponse response) {
//
//       debugPrint("🔔 Notification tapped: ${response.payload}");
//     },
//   );
//
//
//
//   debugPrint("""
// 🛠 Runtime Config:
// - pushNotify: $pushNotify
// - webUrl: $webUrl
// - splashDuration: $splashDuration
// - isSplashEnabled: $isSplashEnabled
// - splashTagline: $splashTagline
// - Permissions:
//   - Camera: $isCameraEnabled
//   - Location: $isLocationEnabled
//   - Mic: $isMicEnabled
//   - Notification: $isNotificationEnabled
//   - Contact: $isContactEnabled
// """);
//
//   if (pushNotify == true) {
//     await Firebase.initializeApp(
//       options: await loadFirebaseOptionsFromJson(),
//     );
//
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     messaging.getToken().then((token) {
//       debugPrint("✅ FCM Token: $token");
//     });
//
//     await messaging.setAutoInitEnabled(true);
//     // await messaging.requestPermission();
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   } else {
//     debugPrint("🚫 Firebase not initialized (pushNotify: $pushNotify, isWeb: $kIsWeb)");
//   }
//   if (webUrl.isEmpty) {
//     debugPrint("❗ Missing WEB_URL environment variable.");
//     runApp(MaterialApp(
//       home: Scaffold(
//         body: Center(child: Text("WEB_URL not configured.")),
//       ),
//     ));
//     return;
//   }
//   runApp(MyApp(webUrl: webUrl, isBottomMenu: isBottomMenu, isSplash: isSplashEnabled, splashLogo: splashUrl, splashBg: splashBgUrl, splashDuration: splashDuration, splashAnimation: splashAnimation, bottomMenuItems: bottomMenuItems));
// }
