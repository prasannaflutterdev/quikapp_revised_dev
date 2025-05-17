#!/bin/bash

echo "🚀 Setting up Android build environment..."

# Create necessary directories
mkdir -p android/app/src/main/res/xml
mkdir -p android/keystore

# Create network_security_config.xml if it doesn't exist
cat > android/app/src/main/res/xml/network_security_config.xml << EOL
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
EOL

# Create backup_rules.xml if it doesn't exist
cat > android/app/src/main/res/xml/backup_rules.xml << EOL
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="sharedpref" path="."/>
    <exclude domain="sharedpref" path="device.xml"/>
</full-backup-content>
EOL

# Set up keystore
if [ -n "$KEY_STORE" ]; then
    echo "🔑 Setting up Android keystore..."
    echo "$KEY_STORE" | base64 --decode > android/keystore/release.keystore
    
    # Verify keystore
    if [ ! -f android/keystore/release.keystore ]; then
        echo "❌ Error: Failed to decode and save keystore"
        exit 1
    fi
    
    # Update key.properties
    cat > android/key.properties << EOL
storePassword=$CM_KEYSTORE_PASSWORD
keyPassword=$CM_KEY_PASSWORD
keyAlias=$CM_KEY_ALIAS
storeFile=keystore/release.keystore
EOL
else
    echo "⚠️ Warning: KEY_STORE not provided, using debug signing"
fi

# Set up Firebase if enabled
if [ "$PUSH_NOTIFY" = "true" ] && [ -n "$firebase_config_android" ]; then
    echo "🔥 Setting up Firebase..."
    mkdir -p android/app/src/
    curl -o android/app/google-services.json "$firebase_config_android"
    
    if [ ! -f android/app/google-services.json ]; then
        echo "❌ Error: Failed to download google-services.json"
        exit 1
    fi
fi

# Create strings.xml with app name
mkdir -p android/app/src/main/res/values
cat > android/app/src/main/res/values/strings.xml << EOL
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$APP_NAME</string>
    <color name="notification_color">#FFFFFF</color>
</resources>
EOL

echo "✅ Android setup completed successfully!" 