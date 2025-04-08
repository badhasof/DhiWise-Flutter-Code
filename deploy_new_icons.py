#!/usr/bin/env python3
import os
import shutil

# Paths
SOURCE_DIR = 'ios/Runner/Assets.xcassets/AppIcon.appiconset/LinguaAppIcon'
TARGET_DIR = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'

def move_icons():
    """Move all icon files from LinguaAppIcon to the main AppIcon.appiconset directory."""
    # Get list of files in the source directory
    files = os.listdir(SOURCE_DIR)
    
    # Move each file to the target directory
    for file in files:
        source_path = os.path.join(SOURCE_DIR, file)
        target_path = os.path.join(TARGET_DIR, file)
        
        # Skip directories
        if os.path.isdir(source_path):
            continue
            
        # Copy the file
        shutil.copy2(source_path, target_path)
        print(f"Moved: {file}")
    
    print("\nAll icons have been moved successfully!")
    print("You can now safely delete the LinguaAppIcon directory if you want.")

if __name__ == "__main__":
    move_icons() 