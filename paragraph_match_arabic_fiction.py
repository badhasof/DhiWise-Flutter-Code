import json

def match_paragraphs(english_text, arabic_text):
    """
    Restructure the Arabic text to match the paragraph structure of the English text.
    1. Count paragraphs in English text
    2. Remove all newlines from Arabic text
    3. Split Arabic text into roughly the same number of paragraphs
    """
    # Count paragraphs in English text (separated by double newlines)
    english_paragraphs = english_text.split('\n\n')
    num_paragraphs = len(english_paragraphs)
    
    # Remove all newlines from Arabic text and get a clean single string
    arabic_text_clean = arabic_text.replace('\n', ' ').strip()
    
    # If there's only one paragraph, return the cleaned text
    if num_paragraphs <= 1:
        return arabic_text_clean
    
    # Calculate roughly how to split the Arabic text
    arabic_words = arabic_text_clean.split()
    total_words = len(arabic_words)
    words_per_paragraph = total_words // num_paragraphs
    
    # Create new paragraphs for Arabic text
    new_arabic_paragraphs = []
    for i in range(num_paragraphs - 1):
        start_idx = i * words_per_paragraph
        end_idx = (i + 1) * words_per_paragraph
        paragraph = ' '.join(arabic_words[start_idx:end_idx])
        new_arabic_paragraphs.append(paragraph)
    
    # Add the last paragraph with remaining words
    last_paragraph = ' '.join(arabic_words[(num_paragraphs - 1) * words_per_paragraph:])
    new_arabic_paragraphs.append(last_paragraph)
    
    # Join paragraphs with double newlines
    return '\n\n'.join(new_arabic_paragraphs)

# Path to the JSON file for fiction stories
json_file_path = 'assets/msa_stories.json'

# Read the JSON file
with open(json_file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Process all stories in the JSON file
if data and "stories" in data and len(data["stories"]) > 0:
    modified_count = 0
    
    for story in data["stories"]:
        if "content_ar" in story and "content_en" in story:
            # Apply paragraph matching
            original_arabic = story["content_ar"]
            story["content_ar"] = match_paragraphs(story["content_en"], story["content_ar"])
            
            # Only count as modified if something changed
            if original_arabic != story["content_ar"]:
                modified_count += 1
                
                # Print paragraph counts for verification
                en_paragraphs = story["content_en"].split('\n\n')
                ar_paragraphs = story["content_ar"].split('\n\n')
                print(f"Modified story {story['id']}:")
                print(f"  English paragraphs: {len(en_paragraphs)}")
                print(f"  Arabic paragraphs: {len(ar_paragraphs)}")
    
    # Save the modified JSON back to the file
    with open(json_file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\nUpdated {json_file_path} successfully!")
    print(f"Total stories modified: {modified_count}")
else:
    print("No stories found in the JSON data!") 