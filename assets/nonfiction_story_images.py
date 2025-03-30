import json
import os

def get_nonfiction_story_titles():
    """
    Extract only nonfiction story titles from the JSON story files
    """
    titles = []
    # Only include the nonfiction story file
    story_paths = [
        "assets/stories_json/msa/msa_stories_nonfiction.json"
    ]
    
    for path in story_paths:
        try:
            with open(path, 'r', encoding='utf-8') as file:
                data = json.load(file)
                if 'stories' in data:
                    for story in data['stories']:
                        if 'title_en' in story:
                            titles.append({
                                'id': story.get('id', ''),
                                'title_en': story['title_en']
                            })
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(f"Error reading {path}: {e}")
    
    return titles 