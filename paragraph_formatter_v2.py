import json
import os
import re
import glob

def count_paragraphs(text):
    """Count the number of paragraphs in a text."""
    if not text:
        return 0
    # Count paragraphs by looking for double newlines or paragraph separators
    paragraphs = re.split(r'\n\n|\r\n\r\n', text)
    # Filter out empty paragraphs
    paragraphs = [p.strip() for p in paragraphs if p.strip()]
    return len(paragraphs)

def split_text_into_paragraphs(text, min_paragraphs=2):
    """Split a text into at least min_paragraphs paragraphs."""
    if not text:
        return text
    
    # If already has paragraphs, return as is
    if count_paragraphs(text) >= min_paragraphs:
        return text
    
    # Try to split on common sentence endings for both Arabic and English
    sentences = re.split(r'([.؟!،]\s+|[.?!]\s+)', text)
    
    # If we don't have enough sentences, just split by length
    if len(sentences) < 3:  
        midpoint = len(text) // min_paragraphs
        paragraphs = []
        for i in range(min_paragraphs):
            start = i * midpoint
            end = (i + 1) * midpoint if i < min_paragraphs - 1 else len(text)
            paragraphs.append(text[start:end])
        return '\n\n'.join(paragraphs)
    
    # Combine sentences with their punctuation
    combined = []
    for i in range(0, len(sentences) - 1, 2):
        if i + 1 < len(sentences):
            combined.append(sentences[i] + sentences[i+1])
        else:
            combined.append(sentences[i])
    
    # If we couldn't combine sentences properly, fall back to length-based splitting
    if len(combined) < 2:
        midpoint = len(text) // min_paragraphs
        paragraphs = []
        for i in range(min_paragraphs):
            start = i * midpoint
            end = (i + 1) * midpoint if i < min_paragraphs - 1 else len(text)
            paragraphs.append(text[start:end])
        return '\n\n'.join(paragraphs)
    
    # Determine how many sentences to include per paragraph
    sentences_per_paragraph = max(1, len(combined) // min_paragraphs)
    
    # Group sentences into paragraphs
    paragraphs = []
    current_paragraph = []
    
    for i, sentence in enumerate(combined):
        current_paragraph.append(sentence)
        if (i + 1) % sentences_per_paragraph == 0 and i < len(combined) - 1:
            paragraphs.append(''.join(current_paragraph))
            current_paragraph = []
    
    # Add any remaining sentences to the last paragraph
    if current_paragraph:
        paragraphs.append(''.join(current_paragraph))
    
    # Ensure we have at least min_paragraphs
    if len(paragraphs) < min_paragraphs:
        # Split the largest paragraph
        largest_idx = 0
        largest_len = 0
        for i, p in enumerate(paragraphs):
            if len(p) > largest_len:
                largest_len = len(p)
                largest_idx = i
        
        # Split the largest paragraph in half
        p = paragraphs[largest_idx]
        midpoint = len(p) // 2
        paragraphs[largest_idx] = p[:midpoint]
        paragraphs.insert(largest_idx + 1, p[midpoint:])
    
    return '\n\n'.join(paragraphs)

def process_story_file(file_path):
    """Process a story JSON file to ensure paragraph consistency for both Arabic and English."""
    print(f"Processing {file_path}...")
    modified = False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for story in data.get('stories', []):
        # Check content_ar and content_en (or story_content for some formats)
        ar_content = story.get('content_ar', '')
        en_content = story.get('content_en', '')
        
        # For some files, use story_content instead of content_ar if it exists
        if 'story_content' in story:
            ar_content = story.get('story_content', '')
        
        # Skip if content is missing
        if not ar_content or not en_content:
            continue
        
        ar_paragraphs = count_paragraphs(ar_content)
        en_paragraphs = count_paragraphs(en_content)
        
        # Fix English content if it has fewer than 2 paragraphs
        if en_paragraphs < 2:
            print(f"  - Fixing English '{story.get('title_en', 'Untitled')}': {en_paragraphs} paragraphs")
            new_en_content = split_text_into_paragraphs(en_content, 2)
            story['content_en'] = new_en_content
            en_paragraphs = count_paragraphs(new_en_content)
            modified = True
        
        # Fix Arabic content if paragraph counts don't match or it has fewer than 2 paragraphs
        if ar_paragraphs != en_paragraphs or ar_paragraphs < 2:
            print(f"  - Fixing Arabic '{story.get('title_en', 'Untitled')}': {ar_paragraphs} Arabic vs {en_paragraphs} English paragraphs")
            
            # Format the Arabic content to match English paragraph count or ensure at least 2 paragraphs
            target_paragraphs = max(en_paragraphs, 2)
            new_ar_content = split_text_into_paragraphs(ar_content, target_paragraphs)
            
            # Update the story with the new content
            if 'story_content' in story:
                story['story_content'] = new_ar_content
            else:
                story['content_ar'] = new_ar_content
            
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
    
    print(f"Completed! Modified {modified_count} out of {len(json_files)} files.")

if __name__ == "__main__":
    main() 