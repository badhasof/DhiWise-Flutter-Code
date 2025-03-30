import json
import os

def get_story_titles():
    """
    Extract all story titles from the JSON story files
    """
    titles = []
    story_paths = [
        "assets/stories_json/msa/msa_stories.json",
        "assets/stories_json/egyptian/egyptian_stories.json",
        "assets/stories_json/moroccan/moroccan_stories.json",
        "assets/stories_json/jordanian/jordanian_stories.json",
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