#!/bin/bash

# Check if font name is provided
if [ -z "$BOTTOMMENU_FONT" ]; then
    echo "❌ Error: BOTTOMMENU_FONT environment variable is not set"
    echo "Using default font: Roboto"
    BOTTOMMENU_FONT="Roboto"
fi

echo "🎨 Setting up font: $BOTTOMMENU_FONT"

# Install required Python packages
pip install requests pyyaml

# Download the font
python download_single_font.py "$BOTTOMMENU_FONT"
if [ $? -ne 0 ]; then
    echo "❌ Failed to download font"
    exit 1
fi

# Update pubspec.yaml
python update_pubspec_font.py "$BOTTOMMENU_FONT"
if [ $? -ne 0 ]; then
    echo "❌ Failed to update pubspec.yaml"
    exit 1
fi

# Run flutter pub get to update dependencies
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get Flutter dependencies"
    exit 1
fi

echo "✅ Font setup completed successfully" 