import json

def reverse_word_order(text):
    """Reverse the order of words in the text, preserving newlines."""
    lines = text.split('\n')
    reversed_line_words = []
    
    for line in lines:
        # Split by spaces, reverse the words, then join back
        words = line.split(' ')
        reversed_words = words[::-1]
        reversed_line = ' '.join(reversed_words)
        reversed_line_words.append(reversed_line)
    
    return '\n'.join(reversed_line_words)

# Path to the JSON file - updated to use the nonfiction stories
json_file_path = 'assets/msa_stories_nonfiction.json'

# Read the JSON file
with open(json_file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Modify all stories
if data and "stories" in data and len(data["stories"]) > 0:
    modified_count = 0
    
    for story in data["stories"]:
        # Reverse Arabic title
        if "title_ar" in story:
            story["title_ar"] = reverse_word_order(story["title_ar"])
        
        # Reverse Arabic content
        if "content_ar" in story:
            story["content_ar"] = reverse_word_order(story["content_ar"])
        
        modified_count += 1
        print(f"Modified story {modified_count}: {story['id']}")
    
    # Save the modified JSON back to the file
    with open(json_file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"Updated {json_file_path} successfully!")
    print(f"Total stories modified: {modified_count}")
else:
    print("No stories found in the JSON data!") 