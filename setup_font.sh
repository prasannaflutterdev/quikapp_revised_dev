#!/bin/bash

# Exit on any error
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if font name is provided
if [ -z "$BOTTOMMENU_FONT" ]; then
    echo "❌ Error: BOTTOMMENU_FONT environment variable is not set"
    echo "Using default font: Roboto"
    BOTTOMMENU_FONT="Roboto"
fi

echo "🎨 Setting up font: $BOTTOMMENU_FONT"

# Create assets/fonts directory if it doesn't exist
mkdir -p assets/fonts

# Install required Python packages
echo "📦 Installing required Python packages..."
pip install requests pyyaml || pip3 install requests pyyaml

# Download the font
echo "📥 Downloading font files..."
python3 download_single_font.py "$BOTTOMMENU_FONT"
if [ $? -ne 0 ]; then
    echo "❌ Failed to download font"
    exit 1
fi

# Verify font files exist
echo "🔍 Verifying font files..."
for weight in "Regular" "Medium" "Bold"; do
    font_file="assets/fonts/${BOTTOMMENU_FONT}-${weight}.ttf"
    if [ ! -f "$font_file" ]; then
        echo "❌ Font file not found: $font_file"
        exit 1
    else
        echo "✅ Found font file: $font_file"
    fi
done

# Update pubspec.yaml
echo "📝 Updating pubspec.yaml..."
python3 update_pubspec_font.py "$BOTTOMMENU_FONT"
if [ $? -ne 0 ]; then
    echo "❌ Failed to update pubspec.yaml"
    exit 1
fi

# Run flutter pub get to update dependencies
echo "🔄 Running flutter pub get..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get Flutter dependencies"
    exit 1
fi

echo "✅ Font setup completed successfully" 