#!/bin/bash
set -e

echo "🔔 Firebase Push Notification Setup for iOS"

if [ "$PUSH_NOTIFY" = "true" ]; then
  echo "✅ PUSH_NOTIFY is true. Proceeding..."

  # 1. Download and apply Firebase config
  mkdir -p firebase/ios
  if [ -n "$firebase_config_ios" ]; then
    echo "📥 Downloading GoogleService-Info.plist..."
    wget -O firebase/ios/GoogleService-Info.plist "$firebase_config_ios"
  fi

  if [ -f "firebase/ios/GoogleService-Info.plist" ]; then
    cp firebase/ios/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
    echo "✅ GoogleService-Info.plist copied."
  else
    echo "❌ Missing GoogleService-Info.plist. Cannot proceed with Firebase setup."
    exit 1
  fi

  # 2. Update Info.plist for push notifications
  PLIST_FILE="ios/Runner/Info.plist"
  
  # Add background modes for push notifications
  /usr/libexec/PlistBuddy -c "Delete :UIBackgroundModes" "$PLIST_FILE" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :UIBackgroundModes array" "$PLIST_FILE"
  /usr/libexec/PlistBuddy -c "Add :UIBackgroundModes:0 string 'remote-notification'" "$PLIST_FILE"
  
  # Add Firebase configuration
  /usr/libexec/PlistBuddy -c "Delete :FirebaseAppDelegateProxyEnabled" "$PLIST_FILE" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :FirebaseAppDelegateProxyEnabled bool false" "$PLIST_FILE"

  # 3. Download APNs Auth Key if provided
  if [ -n "$APNS_AUTH_KEY_URL" ] && [ -n "$APNS_KEY_ID" ] && [ -n "$APPLE_TEAM_ID" ]; then
    echo "📥 Downloading APNs Auth Key..."
    mkdir -p ios/Runner/APNs
    wget -O ios/Runner/APNs/AuthKey_$APNS_KEY_ID.p8 "$APNS_AUTH_KEY_URL"
    
    # Create APNs configuration file
    cat > ios/Runner/APNs/config.json << EOF
{
  "team_id": "$APPLE_TEAM_ID",
  "key_id": "$APNS_KEY_ID",
  "app_bundle_id": "$BUNDLE_ID"
}
EOF
    echo "✅ APNs configuration completed"
  fi

  # 4. Update Podfile for Firebase
  PODFILE="ios/Podfile"
  if [ -f "$PODFILE" ]; then
    echo "📝 Updating Podfile..."
    
    # Set minimum iOS version to 13.0
    sed -i '' 's/platform :ios, .*/platform :ios, '\''13.0'\''/' "$PODFILE"
    
    # Add Firebase pods if not present
    if ! grep -q "pod 'Firebase/Messaging'" "$PODFILE"; then
      cat >> "$PODFILE" << EOF

# Firebase dependencies
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'Firebase/Analytics'
EOF
    fi
    
    echo "✅ Podfile updated"
  fi

  # 5. Create Firebase configuration file
  cat > ios/Runner/Firebase.swift << EOF
import Foundation
import Firebase

class FirebaseConfiguration {
    static func configure() {
        FirebaseApp.configure()
        
        // Configure Firebase Messaging
        Messaging.messaging().delegate = UIApplication.shared.delegate as? MessagingDelegate
        
        // Request permission for notifications
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
}
EOF

  echo "✅ Firebase iOS setup completed successfully."
else
  echo "⏭️ Skipping Firebase setup (PUSH_NOTIFY != true)"
  # Clean up any existing Firebase files if push notifications are disabled
  rm -f ios/Runner/GoogleService-Info.plist
  rm -rf ios/Runner/APNs
  rm -f ios/Runner/Firebase.swift
fi
