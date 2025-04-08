#!/usr/bin/env python3
import os
import json
import shutil
from PIL import Image

# Paths
SOURCE_DIR = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
SOURCE_IMAGE = os.path.join(SOURCE_DIR, 'Lingua App Design.png')
NEW_DIR = os.path.join(SOURCE_DIR, 'LinguaAppIcon')
CONTENTS_JSON = os.path.join(SOURCE_DIR, 'Contents.json')

def create_directory():
    """Create a new directory for the generated icons."""
    if os.path.exists(NEW_DIR):
        shutil.rmtree(NEW_DIR)
    os.makedirs(NEW_DIR)
    print(f"Created directory: {NEW_DIR}")

def load_json_config():
    """Load the existing Contents.json file."""
    with open(CONTENTS_JSON, 'r') as file:
        return json.load(file)

def generate_icons(config):
    """Generate all icon sizes based on the configuration."""
    # Open the source image
    source_img = Image.open(SOURCE_IMAGE)
    
    # Process each image size defined in Contents.json
    for image_info in config['images']:
        size_str = image_info['size']
        scale_str = image_info['scale']
        filename = image_info['filename']
        
        # Parse size (e.g., "20x20" -> (20, 20) or "83.5x83.5" -> (83.5, 83.5))
        width_str, height_str = size_str.split('x')
        width = float(width_str)
        height = float(height_str)
        
        # Parse scale (e.g., "2x" -> 2)
        scale = int(scale_str.replace('x', ''))
        
        # Calculate final size (convert to int for PIL)
        final_width = int(width * scale)
        final_height = int(height * scale)
        
        # Resize the image
        resized_img = source_img.resize((final_width, final_height), Image.Resampling.LANCZOS)
        
        # Save the resized image to the new directory
        output_path = os.path.join(NEW_DIR, filename)
        resized_img.save(output_path, 'PNG')
        print(f"Generated: {filename} ({final_width}x{final_height})")

def save_json_config(config):
    """Save the config to the new directory."""
    output_path = os.path.join(NEW_DIR, 'Contents.json')
    with open(output_path, 'w') as file:
        json.dump(config, file, indent=2)
    print(f"Generated: Contents.json")

def main():
    print("Starting iOS app icon generation...")
    
    # Check if source image exists
    if not os.path.exists(SOURCE_IMAGE):
        print(f"Error: Source image not found at {SOURCE_IMAGE}")
        return
    
    # Create directory for new icons
    create_directory()
    
    # Load existing configuration
    config = load_json_config()
    
    # Generate icons
    generate_icons(config)
    
    # Save configuration
    save_json_config(config)
    
    print("\nDone! Icon set created successfully.")
    print(f"New icons are available in: {NEW_DIR}")
    print("\nTo use the new icons:")
    print("1. Open your iOS project in Xcode")
    print("2. Replace the existing AppIcon.appiconset with your new LinguaAppIcon folder")
    print("   (or rename LinguaAppIcon to AppIcon.appiconset after backing up the original)")

if __name__ == "__main__":
    main() 