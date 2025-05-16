#!/bin/bash

# Configuration
CERT_PATH="certificates/certificate.p12"
PROFILE_PATH="certificates/profile.mobileprovision"
CERT_PASSWORD="YOUR_CERTIFICATE_PASSWORD"
KEYCHAIN_NAME="ios-build.keychain"
KEYCHAIN_PASSWORD="temporary"

echo "🔐 Setting up iOS code signing..."

# Check if certificate exists
if [ ! -f "$CERT_PATH" ]; then
    echo "❌ Certificate not found at $CERT_PATH"
    exit 1
fi

# Check if provisioning profile exists
if [ ! -f "$PROFILE_PATH" ]; then
    echo "❌ Provisioning profile not found at $PROFILE_PATH"
    exit 1
fi

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

# Install pods if needed
if [ ! -d "Pods" ]; then
    echo "📦 Installing pods..."
    pod install
fi

# Build IPA
echo "🏗️ Building IPA..."
flutter build ipa --release --export-options-plist=ExportOptions.plist

# Clean up
echo "🧹 Cleaning up..."
security delete-keychain "$KEYCHAIN_NAME"

echo "✅ Build complete! Check build/ios/ipa/ for your IPA file." 