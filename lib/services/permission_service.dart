import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/env_config.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._internal();
  factory PermissionService() => instance;
  PermissionService._internal();

  Future<void> requestAllPermissions() async {
    final config = EnvConfig.instance;

    // Request permissions based on configuration
    if (config.isCameraEnabled) {
      await _requestPermission(Permission.camera, 'Camera');
    }

    if (config.isLocationEnabled) {
      await _requestPermission(Permission.locationWhenInUse, 'Location');
    }

    if (config.isMicEnabled) {
      await _requestPermission(Permission.microphone, 'Microphone');
    }

    if (config.isNotificationEnabled) {
      await _requestPermission(Permission.notification, 'Notification');
    }

    if (config.isContactEnabled) {
      await _requestPermission(Permission.contacts, 'Contacts');
    }

    if (config.isCalendarEnabled) {
      await _requestPermission(Permission.calendar, 'Calendar');
    }

    // Storage permission is always requested
    if (config.isStorageEnabled) {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use granular media permissions
        if (await _isAndroid13OrHigher()) {
          await Future.wait([
            _requestPermission(Permission.photos, 'Photos'),
            _requestPermission(Permission.videos, 'Videos'),
            _requestPermission(Permission.audio, 'Audio'),
          ]);
        } else {
          // For older Android versions, use storage permission
          await _requestPermission(Permission.storage, 'Storage');
        }
      } else if (Platform.isIOS) {
        await Future.wait([
          _requestPermission(Permission.photos, 'Photos'),
          _requestPermission(Permission.mediaLibrary, 'Media Library'),
        ]);
      }
    }

    // Handle biometric permission
    if (config.isBiometricEnabled) {
      // Note: Biometric permission is handled by the local_auth plugin
      // No explicit permission request needed as it's handled by the system
      debugPrint(
          'Biometric authentication will be handled by local_auth plugin');
    }
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      return sdkInt >= 33; // Android 13 is API level 33
    }
    return false;
  }

  Future<int> _getAndroidSdkVersion() async {
    try {
      // This is a placeholder. In a real app, you would use platform channels
      // or a package like device_info_plus to get the actual SDK version
      return 33; // Default to Android 13 for now
    } catch (e) {
      debugPrint('Error getting Android SDK version: $e');
      return 0;
    }
  }

  Future<void> _requestPermission(Permission permission, String name) async {
    final status = await permission.status;
    if (!status.isGranted) {
      final result = await permission.request();
      debugPrint('$name permission status: ${result.name}');
    } else {
      debugPrint('$name permission already granted');
    }
  }

  Future<Map<String, bool>> checkPermissionStatuses() async {
    final config = EnvConfig.instance;
    final Map<String, bool> statuses = {};

    if (config.isCameraEnabled) {
      statuses['camera'] = await Permission.camera.isGranted;
    }

    if (config.isLocationEnabled) {
      statuses['location'] = await Permission.locationWhenInUse.isGranted;
    }

    if (config.isMicEnabled) {
      statuses['microphone'] = await Permission.microphone.isGranted;
    }

    if (config.isNotificationEnabled) {
      statuses['notification'] = await Permission.notification.isGranted;
    }

    if (config.isContactEnabled) {
      statuses['contacts'] = await Permission.contacts.isGranted;
    }

    if (config.isCalendarEnabled) {
      statuses['calendar'] = await Permission.calendar.isGranted;
    }

    if (config.isStorageEnabled) {
      if (Platform.isAndroid) {
        if (await _isAndroid13OrHigher()) {
          statuses['photos'] = await Permission.photos.isGranted;
          statuses['videos'] = await Permission.videos.isGranted;
          statuses['audio'] = await Permission.audio.isGranted;
        } else {
          statuses['storage'] = await Permission.storage.isGranted;
        }
      } else if (Platform.isIOS) {
        statuses['photos'] = await Permission.photos.isGranted;
        statuses['mediaLibrary'] = await Permission.mediaLibrary.isGranted;
      }
    }

    if (config.isBiometricEnabled) {
      // Note: Biometric status is handled by local_auth plugin
      statuses['biometric'] =
          true; // Placeholder, actual status should be checked using local_auth
    }

    return statuses;
  }
}
