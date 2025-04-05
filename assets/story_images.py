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

# Recommended prompt for image generation (replaces the old one):
"""
Create a generic, artistic illustration related to the story theme '{title}'. 
The image should be simple, minimalist, and visually appealing. 
DO NOT include any text or words in the image.
Use colors and abstract imagery to convey the general mood rather than detailed scenes.
Make the imagery generic enough that it could apply to various interpretations of the title.
""" 