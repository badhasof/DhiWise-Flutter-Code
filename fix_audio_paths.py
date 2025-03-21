import json

# Path to the JSON file
json_file_path = 'assets/msa_stories.json'

# Read the JSON file
with open(json_file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Check and fix audio paths
if data and "stories" in data:
    modified_count = 0
    
    for story in data["stories"]:
        story_id = story.get('id', 'unknown')
        modified = False
        
        # Check audio paths
        if "audio_ar_male" in story:
            male_path = story["audio_ar_male"]
            print(f"Story '{story_id}' male audio: {male_path}")
            
            # Remove any "assets/" prefix to prevent duplication
            if male_path.startswith("assets/"):
                clean_path = male_path.replace("assets/", "", 1)
            else:
                clean_path = male_path.lstrip('/')
                
            # Set the correct path
            corrected_path = f"data/audio/{story_id}_ar_male.mp3"
            story["audio_ar_male"] = corrected_path
            
            print(f"  Fixed to: {story['audio_ar_male']}")
            modified = True
        
        if "audio_ar_female" in story:
            female_path = story["audio_ar_female"]
            print(f"Story '{story_id}' female audio: {female_path}")
            
            # Remove any "assets/" prefix to prevent duplication
            if female_path.startswith("assets/"):
                clean_path = female_path.replace("assets/", "", 1)
            else:
                clean_path = female_path.lstrip('/')
                
            # Set the correct path
            corrected_path = f"data/audio/{story_id}_ar_female.mp3"
            story["audio_ar_female"] = corrected_path
            
            print(f"  Fixed to: {story['audio_ar_female']}")
            modified = True
        
        if modified:
            modified_count += 1
    
    if modified_count > 0:
        # Save the modified JSON back to the file
        with open(json_file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"\nUpdated {json_file_path} successfully!")
        print(f"Total stories with fixed audio paths: {modified_count}")
    else:
        print("\nNo audio path modifications needed.")
else:
    print("No stories found in the JSON data!") 