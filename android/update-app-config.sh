#!/bin/bash

echo "🔄 Updating Android configuration..."

# Required environment variables check
if [ -z "$PKG_NAME" ] || [ -z "$APP_NAME" ]; then
    echo "❌ Error: PKG_NAME and APP_NAME environment variables must be set"
    exit 1
fi

echo "📱 Package Name: $PKG_NAME"
echo "📱 App Name: $APP_NAME"

# Update AndroidManifest.xml package name
MAIN_MANIFEST="app/src/main/AndroidManifest.xml"
DEBUG_MANIFEST="app/src/debug/AndroidManifest.xml"
PROFILE_MANIFEST="app/src/profile/AndroidManifest.xml"

for MANIFEST in "$MAIN_MANIFEST" "$DEBUG_MANIFEST" "$PROFILE_MANIFEST"
do
    if [ -f "$MANIFEST" ]; then
        echo "📝 Updating package in $MANIFEST"
        sed -i.bak "s/package=\"[^\"]*\"/package=\"$PKG_NAME\"/" "$MANIFEST"
        rm -f "$MANIFEST.bak"
    fi
done

# Update app/src/main/kotlin directory structure
echo "📂 Updating Kotlin package directory structure..."
OLD_PACKAGE_PATH=$(find app/src/main/kotlin -type f -name "*.kt" | head -n 1 | xargs dirname)
if [ -n "$OLD_PACKAGE_PATH" ]; then
    NEW_PACKAGE_PATH="app/src/main/kotlin/$(echo $PKG_NAME | tr '.' '/')"
    mkdir -p "$NEW_PACKAGE_PATH"
    mv $OLD_PACKAGE_PATH/* "$NEW_PACKAGE_PATH/"
    rm -rf $(dirname $OLD_PACKAGE_PATH)
fi

# Update MainActivity.kt package declaration
MAIN_ACTIVITY="app/src/main/kotlin/$(echo $PKG_NAME | tr '.' '/')/MainActivity.kt"
if [ -f "$MAIN_ACTIVITY" ]; then
    echo "📝 Updating MainActivity.kt package"
    sed -i.bak "1s/^package .*/package $PKG_NAME/" "$MAIN_ACTIVITY"
    rm -f "$MAIN_ACTIVITY.bak"
fi

# Update app label in strings.xml
STRINGS_XML="app/src/main/res/values/strings.xml"
if [ -f "$STRINGS_XML" ]; then
    echo "📝 Updating app name in strings.xml"
    # Create strings.xml if it doesn't exist
    if [ ! -f "$STRINGS_XML" ]; then
        mkdir -p "app/src/main/res/values"
        echo '<?xml version="1.0" encoding="utf-8"?><resources></resources>' > "$STRINGS_XML"
    fi
    
    # Update or add app_name
    if grep -q "string name=\"app_name\"" "$STRINGS_XML"; then
        sed -i.bak "s/<string name=\"app_name\">[^<]*<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/" "$STRINGS_XML"
    else
        sed -i.bak "s/<\/resources>/    <string name=\"app_name\">$APP_NAME<\/string>\n<\/resources>/" "$STRINGS_XML"
    fi
    rm -f "$STRINGS_XML.bak"
fi

echo "✅ Android configuration updated successfully" 