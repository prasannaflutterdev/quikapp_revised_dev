import 'dart:convert';

class EnvConfig {
  static final EnvConfig instance = EnvConfig._internal();
  factory EnvConfig() => instance;
  EnvConfig._internal();

  // App Metadata
  String get versionName =>
      const String.fromEnvironment('VERSION_NAME', defaultValue: '1.0.0');
  String get versionCode =>
      const String.fromEnvironment('VERSION_CODE', defaultValue: '1');
  String get appName =>
      const String.fromEnvironment('APP_NAME', defaultValue: 'Pixaware App');
  String get orgName => const String.fromEnvironment('ORG_NAME',
      defaultValue: 'Pixaware Technologies');
  String get webUrl => const String.fromEnvironment('WEB_URL',
      defaultValue: 'https://pixaware.co/');
  String get packageName => const String.fromEnvironment('PKG_NAME',
      defaultValue: 'co.pixaware.Pixaware');
  String get bundleId => const String.fromEnvironment('BUNDLE_ID',
      defaultValue: 'co.pixaware.Pixaware');
  String get emailId =>
      const String.fromEnvironment('EMAIL_ID', defaultValue: '');

  // Feature Flags
  bool get isPushEnabled =>
      const String.fromEnvironment('PUSH_NOTIFY', defaultValue: 'false') ==
      'true';
  bool get isDeeplinkEnabled =>
      const String.fromEnvironment('IS_DEEPLINK', defaultValue: 'false') ==
      'true';
  bool get isSplashEnabled =>
      const String.fromEnvironment('IS_SPLASH', defaultValue: 'false') ==
      'true';
  bool get isPullDownEnabled =>
      const String.fromEnvironment('IS_PULLDOWN', defaultValue: 'false') ==
      'true';
  bool get isBottomMenuEnabled =>
      const String.fromEnvironment('IS_BOTTOMMENU', defaultValue: 'false') ==
      'true';
  bool get isLoadingIndicatorEnabled =>
      const String.fromEnvironment('IS_LOAD_IND', defaultValue: 'true') ==
      'true';

  // Permissions
  bool get isCameraEnabled =>
      const String.fromEnvironment('IS_CAMERA', defaultValue: 'false') ==
      'true';
  bool get isLocationEnabled =>
      const String.fromEnvironment('IS_LOCATION', defaultValue: 'false') ==
      'true';
  bool get isMicEnabled =>
      const String.fromEnvironment('IS_MIC', defaultValue: 'false') == 'true';
  bool get isNotificationEnabled =>
      const String.fromEnvironment('IS_NOTIFICATION', defaultValue: 'true') ==
      'true';
  bool get isContactEnabled =>
      const String.fromEnvironment('IS_CONTACT', defaultValue: 'false') ==
      'true';
  bool get isBiometricEnabled =>
      const String.fromEnvironment('IS_BIOMETRIC', defaultValue: 'false') ==
      'true';
  bool get isCalendarEnabled =>
      const String.fromEnvironment('IS_CALENDAR', defaultValue: 'false') ==
      'true';
  bool get isStorageEnabled =>
      const String.fromEnvironment('IS_STORAGE', defaultValue: 'true') ==
      'true';

  // Assets and UI
  String get logoUrl =>
      const String.fromEnvironment('LOGO_URL', defaultValue: '');
  String get splashImage =>
      const String.fromEnvironment('SPLASH', defaultValue: '');
  String get splashBackground =>
      const String.fromEnvironment('SPLASH_BG', defaultValue: '');
  String get splashBgColor =>
      const String.fromEnvironment('SPLASH_BG_COLOR', defaultValue: '#FFFFFF');
  String get splashTagline =>
      const String.fromEnvironment('SPLASH_TAGLINE', defaultValue: 'Welcome');
  String get splashTaglineColor =>
      const String.fromEnvironment('SPLASH_TAGLINE_COLOR',
          defaultValue: '#000000');
  String get splashAnimation =>
      const String.fromEnvironment('SPLASH_ANIMATION', defaultValue: 'rotate');
  int get splashDuration =>
      int.tryParse(
          const String.fromEnvironment('SPLASH_DURATION', defaultValue: '3')) ??
      3;

  // Firebase Configuration
  String get firebaseConfigAndroid =>
      const String.fromEnvironment('firebase_config_android', defaultValue: '');
  String get firebaseConfigIOS =>
      const String.fromEnvironment('firebase_config_ios', defaultValue: '');

  // iOS Configuration
  String get appleTeamId =>
      const String.fromEnvironment('APPLE_TEAM_ID', defaultValue: '');
  String get apnsKeyId =>
      const String.fromEnvironment('APNS_KEY_ID', defaultValue: '');
  String get apnsAuthKeyUrl =>
      const String.fromEnvironment('APNS_AUTH_KEY_URL', defaultValue: '');

  // Bottom Menu Configuration
  List<Map<String, String>> get bottomMenuItems {
    try {
      const String menuJson =
          String.fromEnvironment('BOTTOMMENU_ITEMS', defaultValue: '[]');
      return (jsonDecode(menuJson) as List)
          .map((item) => Map<String, String>.from(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  String get bottomMenuBgColor =>
      const String.fromEnvironment('BOTTOMMENU_BG_COLOR',
          defaultValue: '#FFFFFF');
  String get bottomMenuIconColor =>
      const String.fromEnvironment('BOTTOMMENU_ICON_COLOR',
          defaultValue: '#888888');
  String get bottomMenuTextColor =>
      const String.fromEnvironment('BOTTOMMENU_TEXT_COLOR',
          defaultValue: '#000000');
  String get bottomMenuFont =>
      const String.fromEnvironment('BOTTOMMENU_FONT', defaultValue: 'Roboto');
  double get bottomMenuFontSize =>
      double.tryParse(const String.fromEnvironment('BOTTOMMENU_FONT_SIZE',
          defaultValue: '12')) ??
      12;
  bool get bottomMenuFontBold =>
      const String.fromEnvironment('BOTTOMMENU_FONT_BOLD',
          defaultValue: 'false') ==
      'true';
  bool get bottomMenuFontItalic =>
      const String.fromEnvironment('BOTTOMMENU_FONT_ITALIC',
          defaultValue: 'false') ==
      'true';
  String get bottomMenuActiveTabColor =>
      const String.fromEnvironment('BOTTOMMENU_ACTIVE_TAB_COLOR',
          defaultValue: '#FF2D55');
  String get bottomMenuIconPosition =>
      const String.fromEnvironment('BOTTOMMENU_ICON_POSITION',
          defaultValue: 'above');
  List<String> get bottomMenuVisibleOn =>
      const String.fromEnvironment('BOTTOMMENU_VISIBLE_ON', defaultValue: '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList();

  // Signing Configuration
  String get certUrl =>
      const String.fromEnvironment('CERT_URL', defaultValue: '');
  String get certPassword =>
      const String.fromEnvironment('CERT_PASSWORD', defaultValue: '');
  String get profileUrl =>
      const String.fromEnvironment('PROFILE_URL', defaultValue: '');
  String get keyStore =>
      const String.fromEnvironment('KEY_STORE', defaultValue: '');
  String get keystorePassword =>
      const String.fromEnvironment('CM_KEYSTORE_PASSWORD', defaultValue: '');
  String get keyAlias =>
      const String.fromEnvironment('CM_KEY_ALIAS', defaultValue: '');
  String get keyPassword =>
      const String.fromEnvironment('CM_KEY_PASSWORD', defaultValue: '');
}
