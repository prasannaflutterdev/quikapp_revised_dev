#!/bin/bash

# Create fonts directory
mkdir -p assets/fonts

# Function to download font
download_font() {
    local url=$1
    local filename=$2
    echo "Downloading $filename..."
    wget -q -O "assets/fonts/$filename" "$url"
}

# Roboto
download_font "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Regular.ttf" "Roboto-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Medium.ttf" "Roboto-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/apache/roboto/static/Roboto-Bold.ttf" "Roboto-Bold.ttf"

# Open Sans
download_font "https://github.com/google/fonts/raw/main/apache/opensans/static/OpenSans-Regular.ttf" "OpenSans-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/apache/opensans/static/OpenSans-Medium.ttf" "OpenSans-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/apache/opensans/static/OpenSans-Bold.ttf" "OpenSans-Bold.ttf"

# Inter
download_font "https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Regular.ttf" "Inter-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Medium.ttf" "Inter-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/inter/static/Inter-Bold.ttf" "Inter-Bold.ttf"

# DM Sans
download_font "https://github.com/google/fonts/raw/main/ofl/dmsans/static/DMSans-Regular.ttf" "DMSans-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/dmsans/static/DMSans-Medium.ttf" "DMSans-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/dmsans/static/DMSans-Bold.ttf" "DMSans-Bold.ttf"

# Lato
download_font "https://github.com/google/fonts/raw/main/ofl/lato/Lato-Regular.ttf" "Lato-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/lato/Lato-Bold.ttf" "Lato-Bold.ttf"

# Source Sans 3
download_font "https://github.com/google/fonts/raw/main/ofl/sourcesans3/static/SourceSans3-Regular.ttf" "SourceSans3-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/sourcesans3/static/SourceSans3-Medium.ttf" "SourceSans3-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/sourcesans3/static/SourceSans3-Bold.ttf" "SourceSans3-Bold.ttf"

# Quicksand
download_font "https://github.com/google/fonts/raw/main/ofl/quicksand/static/Quicksand-Regular.ttf" "Quicksand-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/quicksand/static/Quicksand-Medium.ttf" "Quicksand-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/quicksand/static/Quicksand-Bold.ttf" "Quicksand-Bold.ttf"

# Public Sans
download_font "https://github.com/google/fonts/raw/main/ofl/publicsans/static/PublicSans-Regular.ttf" "PublicSans-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/publicsans/static/PublicSans-Medium.ttf" "PublicSans-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/publicsans/static/PublicSans-Bold.ttf" "PublicSans-Bold.ttf"

# IBM Plex Sans
download_font "https://github.com/google/fonts/raw/main/ofl/ibmplexsans/IBMPlexSans-Regular.ttf" "IBMPlexSans-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/ibmplexsans/IBMPlexSans-Medium.ttf" "IBMPlexSans-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/ibmplexsans/IBMPlexSans-Bold.ttf" "IBMPlexSans-Bold.ttf"

# Montserrat
download_font "https://github.com/google/fonts/raw/main/ofl/montserrat/static/Montserrat-Regular.ttf" "Montserrat-Regular.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/montserrat/static/Montserrat-Medium.ttf" "Montserrat-Medium.ttf"
download_font "https://github.com/google/fonts/raw/main/ofl/montserrat/static/Montserrat-Bold.ttf" "Montserrat-Bold.ttf"

echo "✅ All fonts downloaded successfully!" 