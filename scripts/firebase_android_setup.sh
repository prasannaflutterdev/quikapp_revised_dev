#!/bin/bash
set -e

echo "🔔 Firebase Push Notification Setup for Android"

if [ "$PUSH_NOTIFY" = "true" ]; then
  echo "✅ PUSH_NOTIFY is true. Proceeding..."

  # 1. Download and apply Firebase config
  mkdir -p firebase/android
  if [ -n "$firebase_config_android" ]; then
    echo "📥 Downloading google-services.json..."
    wget -O firebase/android/google-services.json "$firebase_config_android"
  fi

  if [ -f "firebase/android/google-services.json" ]; then
    cp firebase/android/google-services.json android/app/google-services.json
    echo "✅ google-services.json copied."
  else
    echo "❌ Missing google-services.json. Cannot proceed with Firebase setup."
    exit 1
  fi

  # 2. Update root build.gradle
  ROOT_GRADLE="android/build.gradle"
  echo "📝 Updating root build.gradle..."
  
  # Add Google Services plugin to buildscript
  if ! grep -q "com.google.gms:google-services" "$ROOT_GRADLE"; then
    sed -i '' '/dependencies {/a\
        classpath "com.google.gms:google-services:4.4.1"' "$ROOT_GRADLE"
  fi

  # 3. Update app build.gradle
  APP_GRADLE="android/app/build.gradle"
  echo "📝 Updating app build.gradle..."
  
  # Add Google Services plugin
  if ! grep -q "apply plugin: 'com.google.gms.google-services'" "$APP_GRADLE"; then
    echo "apply plugin: 'com.google.gms.google-services'" >> "$APP_GRADLE"
  fi
  
  # Add Firebase dependencies
  if ! grep -q "implementation platform('com.google.firebase:firebase-bom:" "$APP_GRADLE"; then
    sed -i '' '/dependencies {/a\
    implementation platform("com.google.firebase:firebase-bom:32.7.4")\
    implementation "com.google.firebase:firebase-analytics"\
    implementation "com.google.firebase:firebase-messaging"\
    implementation "com.google.firebase:firebase-core"' "$APP_GRADLE"
  fi

  # 4. Update AndroidManifest.xml
  MANIFEST="android/app/src/main/AndroidManifest.xml"
  echo "📝 Updating AndroidManifest.xml..."
  
  # Ensure the manifest has the necessary permissions
  if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
    sed -i '' '/<manifest/a\
    <uses-permission android:name="android.permission.INTERNET"/>' "$MANIFEST"
  fi
  
  if ! grep -q "android.permission.POST_NOTIFICATIONS" "$MANIFEST"; then
    sed -i '' '/<manifest/a\
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>' "$MANIFEST"
  fi

  # Add Firebase service
  if ! grep -q "com.google.firebase.messaging.FirebaseMessagingService" "$MANIFEST"; then
    sed -i '' '/<application/a\
        <service\
            android:name=".java.MyFirebaseMessagingService"\
            android:exported="false">\
            <intent-filter>\
                <action android:name="com.google.firebase.MESSAGING_EVENT" />\
            </intent-filter>\
        </service>' "$MANIFEST"
  fi

  # 5. Create Firebase Messaging Service
  mkdir -p android/app/src/main/java/com/example/app/java
  cat > android/app/src/main/java/com/example/app/java/MyFirebaseMessagingService.java << EOF
package com.example.app.java;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import android.util.Log;

public class MyFirebaseMessagingService extends FirebaseMessagingService {
    private static final String TAG = "MyFirebaseMsgService";
    private static final String CHANNEL_ID = "default_notification_channel_id";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Log.d(TAG, "From: " + remoteMessage.getFrom());

        if (remoteMessage.getNotification() != null) {
            Log.d(TAG, "Message Notification Body: " + remoteMessage.getNotification().getBody());
            sendNotification(
                remoteMessage.getNotification().getTitle(),
                remoteMessage.getNotification().getBody()
            );
        }
    }

    @Override
    public void onNewToken(String token) {
        Log.d(TAG, "Refreshed token: " + token);
        // Handle token refresh
    }

    private void sendNotification(String title, String messageBody) {
        Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this, CHANNEL_ID)
                        .setSmallIcon(getApplicationInfo().icon)
                        .setContentTitle(title)
                        .setContentText(messageBody)
                        .setAutoCancel(true)
                        .setSound(defaultSoundUri)
                        .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                    "Default Channel",
                    NotificationManager.IMPORTANCE_DEFAULT);
            notificationManager.createNotificationChannel(channel);
        }

        notificationManager.notify(0, notificationBuilder.build());
    }
}
EOF

  # 6. Update package name in service file
  sed -i '' "s/com.example.app/$PKG_NAME/g" android/app/src/main/java/com/example/app/java/MyFirebaseMessagingService.java
  
  # Create proper directory structure for the package
  PKG_PATH=$(echo "$PKG_NAME" | tr '.' '/')
  mkdir -p "android/app/src/main/java/$PKG_PATH/java"
  mv android/app/src/main/java/com/example/app/java/MyFirebaseMessagingService.java "android/app/src/main/java/$PKG_PATH/java/"
  rm -rf android/app/src/main/java/com/example/app

  echo "✅ Firebase Android setup completed successfully."
else
  echo "⏭️ Skipping Firebase setup (PUSH_NOTIFY != true)"
  # Clean up any existing Firebase files if push notifications are disabled
  rm -f android/app/google-services.json
  rm -rf "android/app/src/main/java/$PKG_PATH/java/MyFirebaseMessagingService.java"
fi 