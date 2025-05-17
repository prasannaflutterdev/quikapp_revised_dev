#!/bin/bash

echo "🚀 Setting up iOS build environment..."

# Create necessary directories
mkdir -p ios/Runner/Resources
mkdir -p ios/Certificates

# Check for required environment variables
if [ -z "$CERTIFICATE_URL" ] || [ -z "$PROVISIONING_PROFILE_URL" ] || [ -z "$CERTIFICATE_PASSWORD" ]; then
    echo "❌ Error: Required environment variables are missing."
    echo "Please ensure CERTIFICATE_URL, PROVISIONING_PROFILE_URL, and CERTIFICATE_PASSWORD are set."
    exit 1
fi

# Download and install certificates
echo "📥 Downloading certificates..."
curl -o ios/Certificates/certificate.p12 "$CERTIFICATE_URL"
curl -o ios/Certificates/profile.mobileprovision "$PROVISIONING_PROFILE_URL"

# Verify downloads
if [ ! -f ios/Certificates/certificate.p12 ] || [ ! -f ios/Certificates/profile.mobileprovision ]; then
    echo "❌ Error: Failed to download certificates"
    exit 1
fi

# Set up keychain
echo "🔑 Setting up keychain..."
security create-keychain -p "" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "" build.keychain
security set-keychain-settings -t 3600 -l ~/Library/Keychains/build.keychain

# Import certificate
echo "📱 Importing certificate..."
security import ios/Certificates/certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" build.keychain

# Install provisioning profile
echo "📱 Installing provisioning profile..."
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
UUID=$(security cms -D -i ios/Certificates/profile.mobileprovision | plutil -extract UUID raw -)
cp ios/Certificates/profile.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"

# Set up Firebase if enabled
if [ "$PUSH_NOTIFY" = "true" ] && [ -n "$firebase_config_ios" ]; then
    echo "🔥 Setting up Firebase..."
    curl -o ios/Runner/GoogleService-Info.plist "$firebase_config_ios"
    
    if [ ! -f ios/Runner/GoogleService-Info.plist ]; then
        echo "❌ Error: Failed to download GoogleService-Info.plist"
        exit 1
    fi
fi

# Update ExportOptions.plist
cat > ios/ExportOptions.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>teamID</key>
    <string>$APPLE_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>$PROVISIONING_PROFILE_NAME</string>
    </dict>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOL

# Update Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION_NAME" ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION_CODE" ios/Runner/Info.plist

echo "✅ iOS setup completed successfully!" 