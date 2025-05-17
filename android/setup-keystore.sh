#!/bin/bash

echo "📦 Setting up Android keystore..."

# Check if we're running in Codemagic CI
if [ -n "$CM_KEYSTORE_PASSWORD" ]; then
    echo "🔄 Running in Codemagic CI environment"
    
    # Download keystore from URL if provided
    if [ -n "$KEY_STORE" ]; then
        echo "📥 Downloading keystore..."
        if curl -f -o app/keystore.jks "$KEY_STORE"; then
            echo "✅ Keystore downloaded successfully."
        else
            echo "❌ Failed to download keystore."
            exit 1
        fi
    fi

else
    echo "🔄 Running in local development environment"
    
    # Check if keystore exists locally
    if [ ! -f "app/keystore.jks" ]; then
        echo "⚠️ No keystore found. Using debug signing configuration."
        exit 0
    fi
fi

# Write key.properties
echo "📝 Writing key.properties..."
cat > key.properties <<EOF
storeFile=keystore.jks
storePassword=${CM_KEYSTORE_PASSWORD:-debug_password}
keyAlias=${CM_KEY_ALIAS:-debug_alias}
keyPassword=${CM_KEY_PASSWORD:-debug_password}
EOF

if [ -f "key.properties" ]; then
    echo "✅ key.properties written successfully."
else
    echo "❌ Failed to write key.properties."
    exit 1
fi

echo "✅ Keystore setup completed" 