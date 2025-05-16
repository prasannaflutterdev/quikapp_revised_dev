#!/bin/bash

# Configuration - Using environment variables
CERT_URL="${CERT_URL}"
PROFILE_URL="${PROFILE_URL}"
CERT_PASSWORD="${CERT_PASSWORD}"
APPLE_TEAM_ID="${APPLE_TEAM_ID}"
BUNDLE_ID="${BUNDLE_ID}"
VERSION_NAME="${VERSION_NAME}"
VERSION_CODE="${VERSION_CODE}"

# Validate required environment variables
if [ -z "$CERT_URL" ] || [ -z "$PROFILE_URL" ] || [ -z "$CERT_PASSWORD" ] || [ -z "$APPLE_TEAM_ID" ] || [ -z "$BUNDLE_ID" ]; then
    echo "❌ Missing required environment variables. Please set:"
    echo "- CERT_URL: URL to download the certificate"
    echo "- PROFILE_URL: URL to download the provisioning profile"
    echo "- CERT_PASSWORD: Certificate password"
    echo "- APPLE_TEAM_ID: Your Apple Team ID"
    echo "- BUNDLE_ID: Your app's bundle identifier"
    exit 1
fi

KEYCHAIN_NAME="ios-build.keychain"
KEYCHAIN_PASSWORD="temporary"
CERT_PATH="certificates/certificate.p12"
PROFILE_PATH="certificates/profile.mobileprovision"

echo "🔐 Setting up iOS code signing..."

# Create certificates directory
mkdir -p certificates

# Download certificate and provisioning profile
echo "⬇️ Downloading certificate..."
curl -o "$CERT_PATH" "$CERT_URL"
if [ $? -ne 0 ]; then
    echo "❌ Failed to download certificate from $CERT_URL"
    exit 1
fi

echo "⬇️ Downloading provisioning profile..."
curl -o "$PROFILE_PATH" "$PROFILE_URL"
if [ $? -ne 0 ]; then
    echo "❌ Failed to download provisioning profile from $PROFILE_URL"
    exit 1
fi

# Clean up any existing keychain
security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true

# Create and configure keychain
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security default-keychain -s "$KEYCHAIN_NAME"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security set-keychain-settings -t 3600 -u "$KEYCHAIN_NAME"

# Import certificate
echo "📥 Importing certificate..."
security import "$CERT_PATH" -k "$KEYCHAIN_NAME" -P "$CERT_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"

# Set up provisioning profile
echo "📱 Setting up provisioning profile..."
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
PROFILE_UUID=$(/usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin <<< $(security cms -D -i "$PROFILE_PATH"))
cp "$PROFILE_PATH" ~/Library/MobileDevice/Provisioning\ Profiles/$PROFILE_UUID.mobileprovision

echo "✅ Profile UUID: $PROFILE_UUID"

# Generate ExportOptions.plist dynamically
cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>teamID</key>
    <string>$APPLE_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>$(/usr/libexec/PlistBuddy -c "Print :Name" /dev/stdin <<< $(security cms -D -i "$PROFILE_PATH"))</string>
    </dict>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>iCloudContainerEnvironment</key>
    <string>Production</string>
</dict>
</plist>
EOF

# Clean up old builds
rm -rf build/ios/ipa/* 2>/dev/null || true

# Install pods if needed
if [ ! -d "Pods" ]; then
    echo "📦 Installing pods..."
    pod install
fi

# Build IPA with all environment variables
echo "🏗️ Building IPA..."
flutter build ipa \
    --release \
    --export-options-plist=ExportOptions.plist \
    --dart-define=WEB_URL="$WEB_URL" \
    --dart-define=PUSH_NOTIFY="$PUSH_NOTIFY" \
    --dart-define=PKG_NAME="$PKG_NAME" \
    --dart-define=APP_NAME="$APP_NAME" \
    --dart-define=ORG_NAME="$ORG_NAME" \
    --dart-define=VERSION_NAME="$VERSION_NAME" \
    --dart-define=VERSION_CODE="$VERSION_CODE" \
    --dart-define=EMAIL_ID="$EMAIL_ID" \
    --dart-define=IS_SPLASH="$IS_SPLASH" \
    --dart-define=SPLASH="$SPLASH" \
    --dart-define=SPLASH_BG="$SPLASH_BG" \
    --dart-define=SPLASH_ANIMATION="$SPLASH_ANIMATION" \
    --dart-define=SPLASH_BG_COLOR="$SPLASH_BG_COLOR" \
    --dart-define=SPLASH_TAGLINE="$SPLASH_TAGLINE" \
    --dart-define=SPLASH_TAGLINE_COLOR="$SPLASH_TAGLINE_COLOR" \
    --dart-define=SPLASH_DURATION="$SPLASH_DURATION" \
    --dart-define=IS_PULLDOWN="$IS_PULLDOWN" \
    --dart-define=LOGO_URL="$LOGO_URL" \
    --dart-define=IS_BOTTOMMENU="$IS_BOTTOMMENU" \
    --dart-define=BOTTOMMENU_ITEMS="$BOTTOMMENU_ITEMS" \
    --dart-define=BOTTOMMENU_BG_COLOR="$BOTTOMMENU_BG_COLOR" \
    --dart-define=BOTTOMMENU_ICON_COLOR="$BOTTOMMENU_ICON_COLOR" \
    --dart-define=BOTTOMMENU_TEXT_COLOR="$BOTTOMMENU_TEXT_COLOR" \
    --dart-define=BOTTOMMENU_ACTIVE_TAB_COLOR="$BOTTOMMENU_ACTIVE_TAB_COLOR" \
    --dart-define=BOTTOMMENU_ICON_POSITION="$BOTTOMMENU_ICON_POSITION" \
    --dart-define=BOTTOMMENU_VISIBLE_ON="$BOTTOMMENU_VISIBLE_ON" \
    --dart-define=IS_DEEPLINK="$IS_DEEPLINK" \
    --dart-define=IS_LOAD_IND="$IS_LOAD_IND" \
    --dart-define=IS_CAMERA="$IS_CAMERA" \
    --dart-define=IS_LOCATION="$IS_LOCATION" \
    --dart-define=IS_BIOMETRIC="$IS_BIOMETRIC" \
    --dart-define=IS_MIC="$IS_MIC" \
    --dart-define=IS_CONTACT="$IS_CONTACT" \
    --dart-define=IS_CALENDAR="$IS_CALENDAR" \
    --dart-define=IS_NOTIFICATION="$IS_NOTIFICATION" \
    --dart-define=IS_STORAGE="$IS_STORAGE"

# Clean up
echo "🧹 Cleaning up..."
security delete-keychain "$KEYCHAIN_NAME"
rm -f "$CERT_PATH" "$PROFILE_PATH"

echo "✅ Build complete! Check build/ios/ipa/ for your IPA file." 