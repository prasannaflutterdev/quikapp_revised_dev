import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

Future<FirebaseOptions> loadFirebaseOptionsFromJson() async {
  if (kDebugMode) {
    print("🔍 Loading google-services.json from assets...");
  }

  final jsonStr = await rootBundle.loadString('assets/google-services.json');
  if (kDebugMode) {
    print("📄 Raw JSON content loaded:\n$jsonStr");
  }

  final jsonMap = json.decode(jsonStr);
  if (kDebugMode) {
    print("✅ JSON decoded successfully.");
  }

  final clientList = jsonMap['client'];
  if (clientList == null || clientList.isEmpty) {
    throw Exception("❌ 'client' field is missing or empty in google-services.json");
  }

  final client = clientList[0];
  if (kDebugMode) {
    print("📦 Extracted client[0]: $client");
  }

  final apiKeyList = client['api_key'];
  if (apiKeyList == null || apiKeyList.isEmpty) {
    throw Exception("❌ 'api_key' field is missing or empty in client");
  }

  final currentKey = apiKeyList[0]['current_key'];
  final appId = client['client_info']['mobilesdk_app_id'];
  final messagingSenderId = jsonMap['project_info']['project_number'];
  final projectId = jsonMap['project_info']['project_id'];
  final storageBucket = jsonMap['project_info']['storage_bucket'];

  if (kDebugMode) {
    print("✅ Extracted Firebase config:");
    print("- apiKey: $currentKey");
    print("- appId: $appId");
    print("- messagingSenderId: $messagingSenderId");
    print("- projectId: $projectId");
    print("- storageBucket: $storageBucket");
  }


  return FirebaseOptions(
    apiKey: currentKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );
}
// Future<FirebaseOptions> loadFirebaseOptionsFromJson() async {
//   final jsonStr = await rootBundle.loadString('assets/google-services.json');
//   final jsonMap = json.decode(jsonStr);
//   final client = jsonMap['client'][0];
//   return FirebaseOptions(
//     apiKey: client['api_key'][0]['current_key'],
//     appId: client['client_info']['mobilesdk_app_id'],
//     messagingSenderId: jsonMap['project_info']['project_number'],
//     projectId: jsonMap['project_info']['project_id'],
//     storageBucket: jsonMap['project_info']['storage_bucket'],
//   );
// }
