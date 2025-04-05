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

# Recommended prompt for nonfiction image generation (replaces the old one):
"""
Create a generic, artistic illustration related to the nonfiction topic '{title}'. 
The image should be simple, minimalist, and visually appealing. 
DO NOT include any text, words, or labels in the image.
Use colors and abstract symbolism to represent the concept rather than detailed literal scenes.
Make the imagery generic enough that it could apply to various interpretations of the topic.
""" 