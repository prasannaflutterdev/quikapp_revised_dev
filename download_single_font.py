import os
import sys
import requests
from pathlib import Path

def download_font(font_name):
    print(f"🔍 Downloading {font_name} font...")
    
    # Get the script directory
    script_dir = Path(os.path.dirname(os.path.abspath(__file__)))
    
    # Create fonts directory relative to script directory
    fonts_dir = script_dir / 'assets' / 'fonts'
    fonts_dir.mkdir(parents=True, exist_ok=True)
    
    # Font URL mapping using Google Fonts CDN
    font_urls = {
        'Roboto': {
            'Regular': 'https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu72xKKTU1Kvnz.woff2',
            'Medium': 'https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fChc4AMP6lbBP.woff2',
            'Bold': 'https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfChc4AMP6lbBP.woff2'
        },
        'OpenSans': {
            'Regular': 'https://fonts.gstatic.com/s/opensans/v35/memSYaGs126MiZpBA-UvWbX2vVnXBbObj2OVZyOOSr4dVJWUgsjZ0C4n.ttf',
            'Medium': 'https://fonts.gstatic.com/s/opensans/v35/memSYaGs126MiZpBA-UvWbX2vVnXBbObj2OVZyOOSr4dVJWUgsjr0C4n.ttf',
            'Bold': 'https://fonts.gstatic.com/s/opensans/v35/memSYaGs126MiZpBA-UvWbX2vVnXBbObj2OVZyOOSr4dVJWUgsg-1y4n.ttf'
        },
        'Inter': {
            'Regular': 'https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZg.ttf',
            'Medium': 'https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuI6fMZg.ttf',
            'Bold': 'https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuFuYMZg.ttf'
        },
        'DMSans': {
            'Regular': 'https://fonts.gstatic.com/s/dmsans/v14/rP2Hp2ywxg089UriOZQ.ttf',
            'Medium': 'https://fonts.gstatic.com/s/dmsans/v14/rP2Cp2ywxg089UriAWCrOB8.ttf',
            'Bold': 'https://fonts.gstatic.com/s/dmsans/v14/rP2Cp2ywxg089UriASitOB8.ttf'
        },
        'Lato': {
            'Regular': 'https://fonts.gstatic.com/s/lato/v24/S6uyw4BMUTPHvxk.ttf',
            'Bold': 'https://fonts.gstatic.com/s/lato/v24/S6u9w4BMUTPHh6UVew8.ttf'
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
        filepath = fonts_dir / filename
        print(f"📥 Downloading {filename}...")
        
        try:
            response = requests.get(url)
            response.raise_for_status()
            
            with open(filepath, 'wb') as f:
                f.write(response.content)
            print(f"✅ Downloaded {filename}")
            
            # Verify file exists and has content
            if not filepath.exists() or filepath.stat().st_size == 0:
                raise Exception(f"File {filename} was not downloaded correctly")
                
        except Exception as e:
            print(f"❌ Failed to download {filename}: {str(e)}")
            sys.exit(1)
    
    print(f"✅ Successfully downloaded {font_name} font files")
    print(f"📁 Font files are located in: {fonts_dir}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python download_single_font.py <font_name>")
        print("Example: python download_single_font.py Roboto")
        sys.exit(1)
    
    font_name = sys.argv[1]
    download_font(font_name) 