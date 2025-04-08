import json
import os
import re
import glob

def fix_indented_sentences(text):
    """Fix improperly indented sentences and merge them with the previous paragraph."""
    if not text:
        return text
    
    # Split into paragraphs
    paragraphs = re.split(r'\n\n|\r\n\r\n', text)
    
    # Filter out empty paragraphs
    paragraphs = [p.strip() for p in paragraphs if p.strip()]
    
    # If there's only one paragraph or no paragraphs, return as is
    if len(paragraphs) <= 1:
        return text
    
    # Check if the last paragraph is just a single sentence or very short
    # (potentially an improperly indented sentence)
    last_paragraph = paragraphs[-1]
    
    # If last paragraph is short (fewer than 100 characters or less than 25% of the previous paragraph)
    # and doesn't start with typical paragraph opening phrases, merge it
    is_short = len(last_paragraph) < 100
    is_proportionally_short = (len(paragraphs) > 1 and 
                               len(last_paragraph) < 0.25 * len(paragraphs[-2]))
    
    # Detect common paragraph starters in Arabic and English
    common_starters = [
        'in the', 'after', 'when', 'while', 'but ', 'however', 'then ', 
        'as ', 'although', 'meanwhile', 'later', 'finally',
        'في', 'عندما', 'بينما', 'لكن', 'ثم', 'بعد', 'أخيراً', 'على الرغم'
    ]
    
    starts_with_paragraph_starter = any(last_paragraph.lower().startswith(starter) 
                                         for starter in common_starters)
    
    # Count sentences in last paragraph
    sentence_endings = re.findall(r'[.!?؟،]', last_paragraph)
    seems_like_single_sentence = len(sentence_endings) <= 1
    
    if (is_short or is_proportionally_short or seems_like_single_sentence) and not starts_with_paragraph_starter:
        # Merge the last paragraph with the previous one
        if len(paragraphs) >= 2:
            paragraphs[-2] = paragraphs[-2] + " " + paragraphs[-1]
            paragraphs.pop()
    
    return '\n\n'.join(paragraphs)

def process_story_file(file_path):
    """Process a story JSON file to ensure last sentences are not improperly indented."""
    print(f"Processing {file_path}...")
    modified = False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Handle different JSON structure formats
    stories = []
    if 'stories' in data:
        stories = data.get('stories', [])
    elif isinstance(data, list):
        stories = data
    
    for story in stories:
        # Get content fields based on available keys
        ar_content_key = None
        if 'content_ar' in story:
            ar_content_key = 'content_ar'
        elif 'story_content' in story:
            ar_content_key = 'story_content'
        
        en_content_key = 'content_en' if 'content_en' in story else None
        
        # Process Arabic content
        if ar_content_key:
            ar_content = story.get(ar_content_key, '')
            if ar_content:
                new_ar_content = fix_indented_sentences(ar_content)
                if new_ar_content != ar_content:
                    story[ar_content_key] = new_ar_content
                    print(f"  - Fixed Arabic content in '{story.get('title_en', 'Untitled')}'")
                    modified = True
        
        # Process English content
        if en_content_key:
            en_content = story.get(en_content_key, '')
            if en_content:
                new_en_content = fix_indented_sentences(en_content)
                if new_en_content != en_content:
                    story[en_content_key] = new_en_content
                    print(f"  - Fixed English content in '{story.get('title_en', 'Untitled')}'")
                    modified = True
    
    # Save the file if modifications were made
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"  - Saved changes to {file_path}")
    else:
        print(f"  - No changes needed for {file_path}")
    
    return modified

def main():
    # Path to stories directory
    stories_dir = 'assets/stories_json'
    
    # Find all JSON files in the stories directory and its subdirectories
    json_files = glob.glob(f"{stories_dir}/**/*.json", recursive=True)
    
    if not json_files:
        print(f"No JSON files found in {stories_dir}")
        return
    
    print(f"Found {len(json_files)} JSON files to process")
    
    # Process each file
    modified_count = 0
    for file_path in json_files:
        if process_story_file(file_path):
            modified_count += 1
    
    print(f"Completed! Fixed {modified_count} out of {len(json_files)} files.")

if __name__ == "__main__":
    main() 