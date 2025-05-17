import os
import sys
import yaml
from pathlib import Path

def update_pubspec_font(font_name):
    print(f"📝 Updating pubspec.yaml for {font_name} font...")
    
    try:
        # Get the script directory
        script_dir = Path(os.path.dirname(os.path.abspath(__file__)))
        pubspec_path = script_dir / 'pubspec.yaml'
        
        if not pubspec_path.exists():
            raise Exception("pubspec.yaml not found")
        
        # Read existing pubspec.yaml
        with open(pubspec_path, 'r') as f:
            pubspec = yaml.safe_load(f)
        
        # Preserve existing configuration
        if 'flutter' not in pubspec:
            pubspec['flutter'] = {}
        
        if 'uses-material-design' not in pubspec['flutter']:
            pubspec['flutter']['uses-material-design'] = True
            
        # Update or add fonts section
        font_config = {
            'family': font_name,
            'fonts': [
                {'asset': f'assets/fonts/{font_name}-Regular.ttf'},
                {
                    'asset': f'assets/fonts/{font_name}-Medium.ttf',
                    'weight': 500
                },
                {
                    'asset': f'assets/fonts/{font_name}-Bold.ttf',
                    'weight': 700
                }
            ]
        }
        
        # Check if fonts section exists and if this font is already configured
        if 'fonts' not in pubspec['flutter']:
            pubspec['flutter']['fonts'] = []
            
        # Remove existing configuration for this font family if it exists
        pubspec['flutter']['fonts'] = [
            f for f in pubspec['flutter'].get('fonts', [])
            if f.get('family') != font_name
        ]
        
        # Add new font configuration
        pubspec['flutter']['fonts'].append(font_config)
        
        # Write back to pubspec.yaml while preserving formatting
        with open(pubspec_path, 'w') as f:
            yaml.dump(pubspec, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
        
        print(f"✅ Updated pubspec.yaml with {font_name} font configuration")
        
        # Verify the font files exist
        for font_file in [f"{font_name}-{weight}.ttf" for weight in ['Regular', 'Medium', 'Bold']]:
            font_path = script_dir / 'assets' / 'fonts' / font_file
            if not font_path.exists():
                raise Exception(f"Font file not found: {font_file}")
        
    except Exception as e:
        print(f"❌ Failed to update pubspec.yaml: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python update_pubspec_font.py <font_name>")
        print("Example: python update_pubspec_font.py Roboto")
        sys.exit(1)
    
    font_name = sys.argv[1]
    update_pubspec_font(font_name) 