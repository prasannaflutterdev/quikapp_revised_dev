#!/bin/bash

echo "🔄 Updating iOS configuration..."

# Required environment variables check
if [ -z "$BUNDLE_ID" ] || [ -z "$APP_NAME" ]; then
    echo "❌ Error: BUNDLE_ID and APP_NAME environment variables must be set"
    exit 1
fi

echo "📱 Bundle ID: $BUNDLE_ID"
echo "📱 App Name: $APP_NAME"

# Update Info.plist
INFO_PLIST="../ios/Runner/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    echo "📝 Updating Info.plist"
    
    # Update CFBundleIdentifier
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$INFO_PLIST"
    
    # Update CFBundleName
    /usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$INFO_PLIST"
    
    # Update CFBundleDisplayName
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" "$INFO_PLIST"
fi

# Update project.pbxproj
PROJECT_PBXPROJ="../ios/Runner.xcodeproj/project.pbxproj"
if [ -f "$PROJECT_PBXPROJ" ]; then
    echo "📝 Updating project.pbxproj"
    
    # Update PRODUCT_BUNDLE_IDENTIFIER
    sed -i.bak "s/PRODUCT_BUNDLE_IDENTIFIER = .*;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/g" "$PROJECT_PBXPROJ"
    rm -f "$PROJECT_PBXPROJ.bak"
fi

echo "✅ iOS configuration updated successfully" 