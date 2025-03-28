import json

# Load MSA fiction stories for reference
with open('assets/stories_json/msa/msa_stories.json', 'r', encoding='utf-8') as f:
    msa_fiction = json.load(f)

# Load MSA non-fiction stories for reference
with open('assets/stories_json/msa/msa_stories_nonfiction.json', 'r', encoding='utf-8') as f:
    msa_nonfiction = json.load(f)

# Load Moroccan fiction stories
with open('assets/stories_json/moroccan/moroccan_stories.json', 'r', encoding='utf-8') as f:
    moroccan_fiction = json.load(f)

# Load Moroccan non-fiction stories
with open('assets/stories_json/moroccan/moroccan_stories_nonfiction.json', 'r', encoding='utf-8') as f:
    moroccan_nonfiction = json.load(f)

print("Fixing Moroccan stories...")

# Create new story collections
fixed_fiction_stories = []
fixed_nonfiction_stories = []

# Process fiction stories
min_count = min(len(msa_fiction['stories']), len(moroccan_nonfiction['stories']))
for i in range(min_count):
    msa_story = msa_fiction['stories'][i]
    # Get the Arabic content from non-fiction file since it has the fiction content
    arabic_content = moroccan_nonfiction['stories'][i].get('story_content', '')
    arabic_title = moroccan_nonfiction['stories'][i].get('story_title', '')
    
    fixed_story = {
        "id": msa_story.get("id", ""),
        "title_en": msa_story.get("title_en", ""),
        "title_ar": msa_story.get("title_ar", ""),
        "genre": msa_story.get("genre", ""),
        "sub_genre": msa_story.get("sub_genre", ""),
        "level": msa_story.get("level", ""),
        "dialect": "Moroccan Arabic",
        "summary_en": msa_story.get("summary_en", ""),
        "story_title": arabic_title,
        "story_content": arabic_content,
        "content_en": msa_story.get("content_en", "")
    }
    
    fixed_fiction_stories.append(fixed_story)

# Process non-fiction stories
min_count = min(len(msa_nonfiction['stories']), len(moroccan_fiction['stories']))
for i in range(min_count):
    msa_story = msa_nonfiction['stories'][i]
    # Get the Arabic content from fiction file since it has the non-fiction content
    arabic_content = moroccan_fiction['stories'][i].get('story_content', '')
    arabic_title = moroccan_fiction['stories'][i].get('story_title', '')
    
    fixed_story = {
        "id": msa_story.get("id", ""),
        "title_en": msa_story.get("title_en", ""),
        "title_ar": msa_story.get("title_ar", ""),
        "genre": msa_story.get("genre", ""),
        "sub_genre": msa_story.get("sub_genre", ""),
        "level": msa_story.get("level", ""),
        "dialect": "Moroccan Arabic",
        "summary_en": msa_story.get("summary_en", ""),
        "story_title": arabic_title,
        "story_content": arabic_content,
        "content_en": msa_story.get("content_en", "")
    }
    
    fixed_nonfiction_stories.append(fixed_story)

# Save the fixed fiction stories
with open('assets/stories_json/moroccan/moroccan_stories.json', 'w', encoding='utf-8') as f:
    json.dump({"stories": fixed_fiction_stories}, f, ensure_ascii=False, indent=2)

# Save the fixed non-fiction stories
with open('assets/stories_json/moroccan/moroccan_stories_nonfiction.json', 'w', encoding='utf-8') as f:
    json.dump({"stories": fixed_nonfiction_stories}, f, ensure_ascii=False, indent=2)

print(f"Successfully fixed {len(fixed_fiction_stories)} Moroccan fiction stories")
print(f"Successfully fixed {len(fixed_nonfiction_stories)} Moroccan non-fiction stories") 