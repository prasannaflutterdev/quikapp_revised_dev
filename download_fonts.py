import os
import requests
from pathlib import Path

def download_font(url, filename):
    print(f"Downloading {filename}...")
    response = requests.get(url)
    if response.status_code == 200:
        with open(filename, 'wb') as f:
            f.write(response.content)
        print(f"✅ Downloaded {filename}")
    else:
        print(f"❌ Failed to download {filename}")

def main():
    # Create fonts directory
    fonts_dir = Path('assets/fonts')
    fonts_dir.mkdir(parents=True, exist_ok=True)
    os.chdir(fonts_dir)

    # Font URLs
    fonts = {
        'Roboto': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/apache/roboto/static/Roboto-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/apache/roboto/static/Roboto-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/apache/roboto/static/Roboto-Bold.ttf'
        },
        'OpenSans': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/apache/opensans/static/OpenSans-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/apache/opensans/static/OpenSans-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/apache/opensans/static/OpenSans-Bold.ttf'
        },
        'Inter': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/inter/static/Inter-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/ofl/inter/static/Inter-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/inter/static/Inter-Bold.ttf'
        },
        'DMSans': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/dmsans/static/DMSans-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/ofl/dmsans/static/DMSans-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/dmsans/static/DMSans-Bold.ttf'
        },
        'Lato': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/lato/Lato-Regular.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/lato/Lato-Bold.ttf'
        },
        'SourceSans3': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/sourcesans3/static/SourceSans3-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/ofl/sourcesans3/static/SourceSans3-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/sourcesans3/static/SourceSans3-Bold.ttf'
        },
        'Quicksand': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/quicksand/static/Quicksand-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/ofl/quicksand/static/Quicksand-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/quicksand/static/Quicksand-Bold.ttf'
        },
        'PublicSans': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/publicsans/static/PublicSans-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/ofl/publicsans/static/PublicSans-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/publicsans/static/PublicSans-Bold.ttf'
        },
        'IBMPlexSans': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/ibmplexsans/IBMPlexSans-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/ofl/ibmplexsans/IBMPlexSans-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/ibmplexsans/IBMPlexSans-Bold.ttf'
        },
        'Montserrat': {
            'Regular': 'https://raw.githubusercontent.com/google/fonts/main/ofl/montserrat/static/Montserrat-Regular.ttf',
            'Medium': 'https://raw.githubusercontent.com/google/fonts/main/ofl/montserrat/static/Montserrat-Medium.ttf',
            'Bold': 'https://raw.githubusercontent.com/google/fonts/main/ofl/montserrat/static/Montserrat-Bold.ttf'
        }
    }

    # Download all fonts
    for family, weights in fonts.items():
        for weight, url in weights.items():
            filename = f"{family}-{weight}.ttf"
            download_font(url, filename)

if __name__ == '__main__':
    main() 