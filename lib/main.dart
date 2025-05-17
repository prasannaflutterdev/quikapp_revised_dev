import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'module/home/home_screen.dart';
import 'module/splash/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'services/permission_service.dart';
import 'config/env_config.dart';
import 'config/config_validator.dart';
import 'services/error_handling_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (EnvConfig.instance.isPushEnabled) {
    await Firebase.initializeApp();
    debugPrint('Handling a background message: ${message.messageId}');
    await NotificationService.instance.showNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
      imageUrl:
          message.notification?.android?.imageUrl ?? message.data['image'],
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final errorHandler = ErrorHandlingService.instance;
  final config = EnvConfig.instance;

  // Validate configuration
  if (!ConfigValidator.instance.validateConfiguration()) {
    debugPrint(
        '❌ Configuration validation failed. Please check the configuration.');
    // You might want to exit here in production
    // exit(1);
  }

  await errorHandler.wrapError('main.setPreferredOrientations', () async {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  });

  // Request necessary permissions
  await PermissionService.instance.requestAllPermissions();

  // Initialize Firebase if push notifications are enabled
  if (config.isPushEnabled) {
    await errorHandler.wrapError('main.initializeFirebase', () async {
      // Initialize Firebase first
      await FirebaseService.instance.initialize();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      await FlutterLocalNotificationsPlugin().initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
      );

      // Configure foreground notification presentation
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize notification service
      await NotificationService.instance.init();
      debugPrint('✅ Firebase and notifications initialized successfully');
    });
  } else {
    debugPrint('⏭️ Skipping Firebase initialization (PUSH_NOTIFY != true)');
  }

  // Debug configuration
  debugPrint("""
    🛠 Runtime Config:
    - App Name: ${config.appName}
    - Version: ${config.versionName} (${config.versionCode})
    - Package Name: ${config.packageName}
    - Bundle ID: ${config.bundleId}
    
    Features:
    - Push Notifications: ${config.isPushEnabled}
    - Web URL: ${config.webUrl}
    - Splash Screen: ${config.isSplashEnabled}
    - Pull to Refresh: ${config.isPullDownEnabled}
    - Bottom Menu: ${config.isBottomMenuEnabled}
    - Deep Linking: ${config.isDeeplinkEnabled}
    - Loading Indicator: ${config.isLoadingIndicatorEnabled}
    
    Splash Configuration:
    - Image: ${config.splashImage}
    - Background: ${config.splashBackground}
    - Duration: ${config.splashDuration}s
    - Animation: ${config.splashAnimation}
    - Tagline Color: ${config.splashTaglineColor}
    - Background Color: ${config.splashBgColor}
    
    Bottom Menu Configuration:
    - Items: ${config.bottomMenuItems.length}
    - Background Color: ${config.bottomMenuBgColor}
    - Active Tab Color: ${config.bottomMenuActiveTabColor}
    - Text Color: ${config.bottomMenuTextColor}
    - Icon Color: ${config.bottomMenuIconColor}
    - Icon Position: ${config.bottomMenuIconPosition}
    
    Permissions:
    - Camera: ${config.isCameraEnabled}
    - Location: ${config.isLocationEnabled}
    - Microphone: ${config.isMicEnabled}
    - Notifications: ${config.isNotificationEnabled}
    - Contacts: ${config.isContactEnabled}
    - Biometric: ${config.isBiometricEnabled}
    - Calendar: ${config.isCalendarEnabled}
    - Storage: ${config.isStorageEnabled}
  """);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = EnvConfig.instance;

    if (config.webUrl.isEmpty) {
      return MaterialApp(
        title: config.appName,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Text(
              'WEB_URL not configured',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: config.isSplashEnabled ? const SplashScreen() : const HomeScreen(),
    );
  }
}
