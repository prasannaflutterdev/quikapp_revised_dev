#!/bin/bash

echo "Setting up iOS certificates and provisioning profiles..."

# Create necessary directories
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

# Download and install the provisioning profile
if [ -n "$PROVISIONING_PROFILE_URL" ]; then
    echo "Downloading provisioning profile..."
    wget -O ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision "$PROVISIONING_PROFILE_URL"
    
    # Get provisioning profile UUID
    UUID=$(security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision | plutil -extract UUID raw -)
    
    # Rename profile with UUID
    mv ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/$UUID.mobileprovision
fi

# Download and install the certificate
if [ -n "$CERTIFICATE_URL" ]; then
    echo "Downloading signing certificate..."
    wget -O certificate.p12 "$CERTIFICATE_URL"
    
    # Create keychain
    security create-keychain -p "" build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "" build.keychain
    security set-keychain-settings -t 3600 -l ~/Library/Keychains/build.keychain
    
    # Import certificate
    security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" build.keychain
fi

echo "iOS signing setup complete!" 