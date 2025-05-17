import 'package:flutter/foundation.dart';
import 'env_config.dart';

class ConfigValidator {
  static final ConfigValidator instance = ConfigValidator._internal();
  factory ConfigValidator() => instance;
  ConfigValidator._internal();

  bool validateConfiguration() {
    final config = EnvConfig.instance;
    final List<String> errors = [];

    // Validate essential app configuration
    _validateField(errors, 'App Name', config.appName);
    _validateField(errors, 'Web URL', config.webUrl);
    _validateField(errors, 'Package Name', config.packageName);
    _validateField(errors, 'Bundle ID', config.bundleId);

    // Validate push notification configuration if enabled
    if (config.isPushEnabled) {
      _validateField(
          errors, 'Firebase Android Config', config.firebaseConfigAndroid);
      _validateField(errors, 'Firebase iOS Config', config.firebaseConfigIOS);

      // Validate iOS specific configuration
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        _validateField(errors, 'Apple Team ID', config.appleTeamId);
        _validateField(errors, 'APNS Key ID', config.apnsKeyId);
        _validateField(errors, 'APNS Auth Key URL', config.apnsAuthKeyUrl);
      }
    }

    // Validate splash screen configuration if enabled
    if (config.isSplashEnabled) {
      _validateField(errors, 'Splash Image', config.splashImage);
    }

    // Validate bottom menu configuration if enabled
    if (config.isBottomMenuEnabled && config.bottomMenuItems.isEmpty) {
      errors.add('Bottom menu is enabled but no menu items are configured');
    }

    // Log all validation errors
    if (errors.isNotEmpty) {
      debugPrint('❌ Configuration validation failed:');
      for (final error in errors) {
        debugPrint('  • $error');
      }
      return false;
    }

    debugPrint('✅ Configuration validation passed');
    return true;
  }

  void _validateField(List<String> errors, String fieldName, String value) {
    if (value.isEmpty) {
      errors.add('$fieldName is not configured');
    }
  }

  void validatePermissions() {
    final config = EnvConfig.instance;
    final List<String> enabledPermissions = [];

    if (config.isCameraEnabled) enabledPermissions.add('Camera');
    if (config.isLocationEnabled) enabledPermissions.add('Location');
    if (config.isMicEnabled) enabledPermissions.add('Microphone');
    if (config.isNotificationEnabled) enabledPermissions.add('Notifications');
    if (config.isContactEnabled) enabledPermissions.add('Contacts');
    if (config.isBiometricEnabled) enabledPermissions.add('Biometric');
    if (config.isCalendarEnabled) enabledPermissions.add('Calendar');
    if (config.isStorageEnabled) enabledPermissions.add('Storage');

    debugPrint('📱 Enabled permissions:');
    for (final permission in enabledPermissions) {
      debugPrint('  • $permission');
    }
  }
}
