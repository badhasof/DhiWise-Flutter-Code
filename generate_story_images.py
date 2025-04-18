import base64
import os
import mimetypes
import time
from google import genai
from google.genai import types
from assets.story_images import get_story_titles


def save_binary_file(file_name, data):
    f = open(file_name, "wb")
    f.write(data)
    f.close()


def generate():
    client = genai.Client(
        api_key=os.environ.get("GEMINI_API_KEY"),
    )

    model = "gemini-2.0-flash-exp-image-generation"
    
    # Get all story titles
    stories = get_story_titles()
    print(f"Total stories found: {len(stories)}")
    
    # Check for already generated images
    existing_images = set()
    if os.path.exists("assets/story_images"):
        for file in os.listdir("assets/story_images"):
            name = os.path.splitext(file)[0]  # Get filename without extension
            existing_images.add(name)
    print(f"Total existing images found: {len(existing_images)}")
    print(f"Existing images: {', '.join(list(existing_images)[:10])}...")
    
    # Count how many stories need images
    stories_needing_images = []
    for story in stories:
        story_id = story['id']
        if story_id not in existing_images:
            stories_needing_images.append(story)
    
    print(f"Stories needing images: {len(stories_needing_images)}")
    if stories_needing_images:
        print(f"First few stories needing images: {[s['title_en'] for s in stories_needing_images[:5]]}")
    else:
        print("No stories need images. All images already exist!")
    
    # Process count for rate limit management
    request_count = 0
    
    for story in stories:
        story_id = story['id']
        title_en = story['title_en']
        
        # Skip if this image already exists
        if story_id in existing_images:
            # print(f"Skipping {title_en} - image already exists")
            continue
        
        print(f"Generating image for: {title_en}")
        
        # Rate limit management - pause every 9 requests
        request_count += 1
        if request_count > 1 and request_count % 9 == 0:
            print("Approaching rate limit, pausing for 60 seconds...")
            time.sleep(10)
        
        # Improved prompt for better thumbnail images
        prompt = f"Create a high-quality thumbnail image for a story titled '{title_en}'. The image should capture the essence of the story title and be visually appealing as a small thumbnail in a story app. No text in the image."
        
        # Retry logic
        max_retries = 3
        for attempt in range(max_retries):
            try:
                contents = [
                    types.Content(
                        role="user",
                        parts=[
                            types.Part.from_text(text=prompt),
                        ],
                    ),
                ]
                
                generate_content_config = types.GenerateContentConfig(
                    response_modalities=[
                        "image",
                        "text",
                    ],
                    response_mime_type="text/plain",
                )

                image_generated = False
                for chunk in client.models.generate_content_stream(
                    model=model,
                    contents=contents,
                    config=generate_content_config,
                ):
                    if not chunk.candidates or not chunk.candidates[0].content or not chunk.candidates[0].content.parts:
                        continue
                    if chunk.candidates[0].content.parts[0].inline_data:
                        file_name = f"assets/story_images/{story_id}"
                        inline_data = chunk.candidates[0].content.parts[0].inline_data
                        file_extension = mimetypes.guess_extension(inline_data.mime_type)
                        save_binary_file(
                            f"{file_name}{file_extension}", inline_data.data
                        )
                        print(
                            f"File of mime type {inline_data.mime_type} saved to: {file_name}{file_extension}"
                        )
                        image_generated = True
                    else:
                        print(chunk.text)
                
                # If image was generated successfully, break the retry loop
                if image_generated:
                    # Add a small delay between requests (even successful ones)
                    time.sleep(6)
                    break
                    
                # If no image was generated, retry
                print(f"No image generated for {title_en}, retrying...")
                time.sleep(10)  # Wait before retry
                
            except Exception as e:
                error_message = str(e)
                print(f"Error: {error_message}")
                
                # Handle rate limit errors
                if "RESOURCE_EXHAUSTED" in error_message or "429" in error_message:
                    retry_delay = 65  # Default 65 seconds
                    # Try to extract the retry delay from the error message
                    if "retryDelay" in error_message:
                        try:
                            retry_part = error_message.split("retryDelay:")[1].split("s")[0].strip()
                            extracted_delay = int(retry_part)
                            retry_delay = extracted_delay + 5  # Add buffer
                        except:
                            pass
                            
                    print(f"Rate limit exceeded. Waiting {retry_delay} seconds before retrying...")
                    time.sleep(retry_delay)
                else:
                    # For other errors, use a shorter delay
                    wait_time = (attempt + 1) * 10  # Exponential backoff
                    print(f"Attempt {attempt+1}/{max_retries} failed. Waiting {wait_time} seconds...")
                    time.sleep(wait_time)
                
                # If we've exhausted all retries
                if attempt == max_retries - 1:
                    print(f"Failed to generate image for {title_en} after {max_retries} attempts")

if __name__ == "__main__":
    # Create directory if it doesn't exist
    os.makedirs("assets/story_images", exist_ok=True)
    generate()
