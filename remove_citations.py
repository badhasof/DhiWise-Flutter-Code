#!/usr/bin/env python3
import json
import re

# List of paths to story JSON files for different dialects
file_paths = [
    # Non-fiction story files
    'assets/stories_json/egyptian/egyptian_stories_nonfiction.json',
    'assets/stories_json/jordanian/jordanian_stories_nonfiction.json',
    'assets/stories_json/moroccan/moroccan_stories_nonfiction.json',
    # Main story files (including fiction)
    'assets/stories_json/egyptian/egyptian_stories.json',
    'assets/stories_json/jordanian/jordanian_stories.json',
    'assets/stories_json/moroccan/moroccan_stories.json'
]

# Regular expression pattern to match citations [cite: number]
citation_pattern = r'\[cite: \d+\]'

# Total count of citations removed across all files
total_citations_removed = 0

# Process each file
for file_path in file_paths:
    try:
        # Read the JSON file
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Count of citations removed from this file
        file_citations_removed = 0
        
        # Process each story
        for story in data.get('stories', []):
            # Get the story content
            content = story.get('story_content', '')
            
            # Count citations in this story
            citations_in_story = len(re.findall(citation_pattern, content))
            file_citations_removed += citations_in_story
            
            # Remove all citations from the story content
            cleaned_content = re.sub(citation_pattern, '', content)
            
            # Update the story content with cleaned text
            story['story_content'] = cleaned_content
            
            print(f"Processed story: {story.get('title_en', 'Unknown title')} - Removed {citations_in_story} citations")
        
        # Write the updated data back to the file
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"\nFinished processing {file_path}")
        print(f"Citations removed from this file: {file_citations_removed}")
        total_citations_removed += file_citations_removed
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

print(f"\nTotal citations removed from all files: {total_citations_removed}")
print("All files have been updated successfully.")
