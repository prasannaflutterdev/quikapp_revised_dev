import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/env_config.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  factory FirebaseService() => instance;
  FirebaseService._internal();

  Future<void> initialize() async {
    if (!EnvConfig.instance.isPushEnabled) {
      debugPrint(
          'Firebase initialization skipped: Push notifications are disabled');
      return;
    }

    try {
      final options = await _getFirebaseOptions();
      await Firebase.initializeApp(options: options);
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  Future<FirebaseOptions> _getFirebaseOptions() async {
    final config = EnvConfig.instance;

    if (Platform.isIOS) {
      if (config.firebaseConfigIOS.isEmpty) {
        throw Exception('Firebase iOS configuration URL is not provided');
      }

      final plistContent = await _downloadFile(config.firebaseConfigIOS);
      final plistFile =
          await _saveTempFile('GoogleService-Info.plist', plistContent);

      // Parse plist file and create FirebaseOptions
      // Note: You'll need to implement plist parsing logic here
      // For now, returning default options
      return FirebaseOptions(
        apiKey: 'your-api-key',
        appId: 'your-app-id',
        messagingSenderId: 'your-sender-id',
        projectId: 'your-project-id',
        iosBundleId: config.bundleId,
      );
    } else {
      if (config.firebaseConfigAndroid.isEmpty) {
        throw Exception('Firebase Android configuration URL is not provided');
      }

      final jsonContent = await _downloadFile(config.firebaseConfigAndroid);
      final Map<String, dynamic> jsonData = json.decode(jsonContent);

      return FirebaseOptions(
        apiKey: jsonData['client'][0]['api_key'][0]['current_key'],
        appId: jsonData['client'][0]['client_info']['mobilesdk_app_id'],
        messagingSenderId: jsonData['project_info']['project_number'],
        projectId: jsonData['project_info']['project_id'],
        storageBucket: jsonData['project_info']['storage_bucket'],
      );
    }
  }

  Future<String> _downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      }
      throw Exception('Failed to download file: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error downloading file: $e');
      rethrow;
    }
  }

  Future<File> _saveTempFile(String filename, String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    return file;
  }
}
