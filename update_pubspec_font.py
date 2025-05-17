import sys
import yaml

def update_pubspec_font(font_name):
    print(f"📝 Updating pubspec.yaml for {font_name} font...")
    
    try:
        with open('pubspec.yaml', 'r') as f:
            pubspec = yaml.safe_load(f)
        
        # Create or update the fonts section
        if 'flutter' not in pubspec:
            pubspec['flutter'] = {}
        
        pubspec['flutter']['fonts'] = [{
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
        }]
        
        # Write back to pubspec.yaml
        with open('pubspec.yaml', 'w') as f:
            yaml.dump(pubspec, f, default_flow_style=False, sort_keys=False)
        
        print(f"✅ Updated pubspec.yaml with {font_name} font configuration")
        
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