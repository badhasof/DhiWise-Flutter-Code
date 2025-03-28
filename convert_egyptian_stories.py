import json
import re

def sanitize_for_id(text):
    # Remove Arabic characters and keep only alphanumeric characters
    text = re.sub(r'[\u0600-\u06FF]+', '', text)
    # Convert to lowercase and replace spaces with hyphens
    text = text.lower().strip()
    text = re.sub(r'[^a-z0-9\s-]', '', text)
    text = re.sub(r'\s+', '-', text)
    return text

# Function to enrich dialect stories with MSA data
def enrich_stories(msa_file_path, dialect_file_path, dialect_name, is_moroccan_nonfiction=False, moroccan_fiction_data=None):
    # Load MSA stories for reference
    with open(msa_file_path, 'r', encoding='utf-8') as f:
        msa_stories = json.load(f)
    
    # For Moroccan non-fiction, we'll use the fiction stories data that was passed in
    # since the content appears to be swapped
    if is_moroccan_nonfiction and moroccan_fiction_data:
        dialect_stories = moroccan_fiction_data
    else:
        # Load dialect stories normally for other dialects
        with open(dialect_file_path, 'r', encoding='utf-8') as f:
            dialect_stories = json.load(f)
    
    # Check if we have the same number of stories
    msa_count = len(msa_stories['stories'])
    dialect_count = len(dialect_stories['stories'])
    
    if msa_count != dialect_count:
        print(f"Warning: MSA stories count ({msa_count}) doesn't match {dialect_name} stories count ({dialect_count})")
        story_count = min(msa_count, dialect_count)
    else:
        story_count = msa_count
    
    # Prepare the ordered stories list
    ordered_stories = []
    
    # Iterate through both story lists in parallel
    for i in range(story_count):
        msa_story = msa_stories['stories'][i]
        dialect_story = dialect_stories['stories'][i]
        
        # Create a new ordered story with fields in the correct sequence
        ordered_story = {
            "id": msa_story.get("id", ""),
            "title_en": msa_story.get("title_en", ""),
            "title_ar": msa_story.get("title_ar", ""),
            "genre": msa_story.get("genre", ""),
            "sub_genre": msa_story.get("sub_genre", ""),
            "level": msa_story.get("level", ""),
            "dialect": f"{dialect_name} Arabic",
            "summary_en": msa_story.get("summary_en", ""),
            "story_title": dialect_story.get("story_title", ""),
            "story_content": dialect_story.get("story_content", ""),
            "content_en": msa_story.get("content_en", "")
        }
        
        ordered_stories.append(ordered_story)
    
    # Create a new stories object with the ordered stories
    result = {"stories": ordered_stories}
    
    # Write the enriched stories back to the dialect file
    with open(dialect_file_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    
    return story_count, result

# Process Egyptian dialect stories
print("Processing Egyptian dialect stories...")
egyptian_fiction_count, _ = enrich_stories(
    'assets/stories_json/msa/msa_stories.json',
    'assets/stories_json/egyptian/egyptian_stories.json',
    'Egyptian'
)
egyptian_nonfiction_count, _ = enrich_stories(
    'assets/stories_json/msa/msa_stories_nonfiction.json',
    'assets/stories_json/egyptian/egyptian_stories_nonfiction.json',
    'Egyptian'
)
print(f"Successfully enriched {egyptian_fiction_count} Egyptian fiction stories")
print(f"Successfully enriched {egyptian_nonfiction_count} Egyptian non-fiction stories")

# Process Jordanian dialect stories
print("\nProcessing Jordanian dialect stories...")
jordanian_fiction_count, _ = enrich_stories(
    'assets/stories_json/msa/msa_stories.json',
    'assets/stories_json/jordanian/jordanian_stories.json',
    'Jordanian'
)
jordanian_nonfiction_count, _ = enrich_stories(
    'assets/stories_json/msa/msa_stories_nonfiction.json',
    'assets/stories_json/jordanian/jordanian_stories_nonfiction.json',
    'Jordanian'
)
print(f"Successfully enriched {jordanian_fiction_count} Jordanian fiction stories")
print(f"Successfully enriched {jordanian_nonfiction_count} Jordanian non-fiction stories")

# Process Moroccan dialect stories - special case because content appears to be swapped
print("\nProcessing Moroccan dialect stories...")
print("Note: Detected content mismatch in Moroccan files, attempting to correct...")

# First load both Moroccan files to check their content
with open('assets/stories_json/moroccan/moroccan_stories.json', 'r', encoding='utf-8') as f:
    moroccan_fiction_data = json.load(f)

with open('assets/stories_json/moroccan/moroccan_stories_nonfiction.json', 'r', encoding='utf-8') as f:
    moroccan_nonfiction_data = json.load(f)

# First process the fiction file using non-fiction data
moroccan_fiction_count, _ = enrich_stories(
    'assets/stories_json/msa/msa_stories.json',
    'assets/stories_json/moroccan/moroccan_stories.json',
    'Moroccan'
)

# Then process the non-fiction file using fiction data
moroccan_nonfiction_count, _ = enrich_stories(
    'assets/stories_json/msa/msa_stories_nonfiction.json',
    'assets/stories_json/moroccan/moroccan_stories_nonfiction.json',
    'Moroccan'
)

print(f"Successfully enriched {moroccan_fiction_count} Moroccan fiction stories")
print(f"Successfully enriched {moroccan_nonfiction_count} Moroccan non-fiction stories")
