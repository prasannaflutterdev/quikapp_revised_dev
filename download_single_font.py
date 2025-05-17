import os
import sys
import requests
from pathlib import Path

def download_font(font_name):
    print(f"🔍 Downloading {font_name} font...")
    
    # Create fonts directory
    fonts_dir = Path('assets/fonts')
    fonts_dir.mkdir(parents=True, exist_ok=True)
    os.chdir(fonts_dir)
    
    # Font URL mapping
    font_urls = {
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
    
    if font_name not in font_urls:
        print(f"❌ Error: Font '{font_name}' not found in supported fonts list")
        print("Supported fonts:", ", ".join(font_urls.keys()))
        sys.exit(1)
    
    # Download font files
    for weight, url in font_urls[font_name].items():
        filename = f"{font_name}-{weight}.ttf"
        print(f"📥 Downloading {filename}...")
        
        try:
            response = requests.get(url)
            response.raise_for_status()
            
            with open(filename, 'wb') as f:
                f.write(response.content)
            print(f"✅ Downloaded {filename}")
        except Exception as e:
            print(f"❌ Failed to download {filename}: {str(e)}")
            sys.exit(1)
    
    print(f"✅ Successfully downloaded {font_name} font files")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python download_single_font.py <font_name>")
        print("Example: python download_single_font.py Roboto")
        sys.exit(1)
    
    font_name = sys.argv[1]
    download_font(font_name) 