import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'module/home/home_screen.dart';
import 'module/splash/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'services/permission_service.dart';
import 'config/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final config = EnvConfig.instance;

  // Request necessary permissions
  await PermissionService.instance.requestAllPermissions();

  // Initialize Firebase if push notifications are enabled
  if (config.isPushEnabled) {
    try {
      await FirebaseService.instance.initialize();
      await NotificationService.instance.init();
      debugPrint('Firebase and notifications initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase and notifications: $e');
    }
  }

  // Debug configuration
  debugPrint("""
    🛠 Runtime Config:
    - pushNotify: ${config.isPushEnabled}
    - webUrl: ${config.webUrl}
    - isSplash: ${config.isSplashEnabled}
    - splashImage: ${config.splashImage}
    - splashBackground: ${config.splashBackground}
    - splashDuration: ${config.splashDuration}
    - splashAnimation: ${config.splashAnimation}
    - splashTaglineColor: ${config.splashTaglineColor}
    - splashBgColor: ${config.splashBgColor}
    - isBottomMenu: ${config.isBottomMenuEnabled}
    - bottomMenuItems: ${config.bottomMenuItems}
    - isDeeplink: ${config.isDeeplinkEnabled}
    - bottomMenuBgColor: ${config.bottomMenuBgColor}
    - bottomMenuActiveTabColor: ${config.bottomMenuActiveTabColor}
    - bottomMenuTextColor: ${config.bottomMenuTextColor}
    - bottomMenuIconColor: ${config.bottomMenuIconColor}
    - bottomMenuIconPosition: ${config.bottomMenuIconPosition}
    - Permissions:
      - Camera: ${config.isCameraEnabled}
      - Location: ${config.isLocationEnabled}
      - Mic: ${config.isMicEnabled}
      - Notification: ${config.isNotificationEnabled}
      - Contact: ${config.isContactEnabled}
      - Biometric: ${config.isBiometricEnabled}
      - Calendar: ${config.isCalendarEnabled}
      - Storage: ${config.isStorageEnabled}
  """);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = EnvConfig.instance;

    if (config.webUrl.isEmpty) {
      return MaterialApp(
        title: config.appName,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Text('WEB_URL not configured'),
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
      ),
      home: config.isSplashEnabled ? const SplashScreen() : const HomeScreen(),
    );
  }
}
