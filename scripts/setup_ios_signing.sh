#!/bin/bash

echo "Setting up iOS certificates and provisioning profiles..."

# Create necessary directories
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
mkdir -p ios_certificates

# Check for required environment variables
if [ -z "$CERTIFICATE_URL" ] || [ -z "$PROVISIONING_PROFILE_URL" ] || [ -z "$CERTIFICATE_PASSWORD" ]; then
    echo "❌ Error: Required environment variables are missing."
    echo "Please ensure CERTIFICATE_URL, PROVISIONING_PROFILE_URL, and CERTIFICATE_PASSWORD are set."
    exit 1
fi

echo "📥 Downloading signing certificate..."
curl -o ios_certificates/signing_cert.p12 "$CERTIFICATE_URL"

echo "📥 Downloading provisioning profile..."
curl -o ios_certificates/profile.mobileprovision "$PROVISIONING_PROFILE_URL"

# Verify downloads
if [ ! -f ios_certificates/signing_cert.p12 ] || [ ! -f ios_certificates/profile.mobileprovision ]; then
    echo "❌ Error: Failed to download certificates or provisioning profile."
    exit 1
fi

echo "🔑 Setting up keychain..."
# Create and configure keychain
security create-keychain -p "" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "" build.keychain
security set-keychain-settings -t 3600 -l ~/Library/Keychains/build.keychain

# Import certificate
echo "📱 Importing certificate..."
security import ios_certificates/signing_cert.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" build.keychain

# Install provisioning profile
echo "📱 Installing provisioning profile..."
UUID=$(security cms -D -i ios_certificates/profile.mobileprovision | plutil -extract UUID raw -)
cp ios_certificates/profile.mobileprovision "$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"

echo "✅ iOS signing setup completed successfully!" 