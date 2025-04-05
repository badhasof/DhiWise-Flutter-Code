import os
import mimetypes
import time
from google import genai
from google.genai import types

# List of specific images to regenerate with refined prompts
SELECTED_IMAGES = [
    {"id": "leonardo-da-vinci-the-renaissance-man", "title_en": "Leonardo da Vinci, The Renaissance Man", "prompt_addition": "A minimalist, elegant composition showing a single da Vinci sketch - either the Vitruvian Man or a flying machine blueprint - with soft Renaissance lighting. Beautiful aesthetics with clean lines and simple composition, focusing on the craftsmanship rather than complexity."},
    
    {"id": "cleopatra-the-last-pharaoh", "title_en": "Cleopatra, The Last Pharaoh", "prompt_addition": "A minimal, aesthetic composition featuring a single Egyptian pyramid silhouette against a golden sunset sky. Clean lines, beautiful color gradient, and perhaps a single gold element (like a small scarab) for subtle symbolism. Elegant and not overcrowded."},
    
    {"id": "a-journey-through-the-seven-wonders", "title_en": "A Journey Through the Seven Wonders", "prompt_addition": "A minimalist, aesthetic composition showing just one or two of the seven wonders (perhaps the Pyramids or Colosseum) in a clean, travel-photography style. Beautiful lighting, simple composition, with perhaps a single path element to symbolize the journey. Not cluttered with multiple elements."},
    
    {"id": "resilience-in-the-face-of-adversity", "title_en": "Resilience in the Face of Adversity", "prompt_addition": "A minimal, beautiful image of a single bamboo stalk standing firm against a stormy sky. Clean composition, elegant aesthetics, with dramatic but simple lighting. Focus on the natural beauty and symbolism without overcomplication."},
    
    {"id": "the-silk-road-rediscovered", "title_en": "The Silk Road Rediscovered", "prompt_addition": "A minimal, aesthetic still life featuring a single piece of flowing silk fabric in rich colors against a simple background. Perhaps one small additional element like a compass or spice. Beautiful lighting highlighting the texture of the silk, with a clean, elegant composition."}
]

def save_binary_file(file_name, data):
    f = open(file_name, "wb")
    f.write(data)
    f.close()

def generate():
    client = genai.Client(
        api_key=os.environ.get("GEMINI_API_KEY"),
    )

    model = "gemini-2.0-flash-exp-image-generation"
    
    # Create directories if they don't exist
    os.makedirs("assets/nonfiction_images", exist_ok=True)
    
    # Process count for rate limit management
    request_count = 0
    
    # Process selected images
    print(f"Regenerating {len(SELECTED_IMAGES)} selected images with refined aesthetics")
    
    for story in SELECTED_IMAGES:
        story_id = story['id']
        title_en = story['title_en']
        prompt_addition = story['prompt_addition']
        
        print(f"Generating image for: {title_en}")
        
        # Rate limit management - pause every 3 requests
        request_count += 1
        if request_count > 1 and request_count % 3 == 0:
            print("Approaching rate limit, pausing for 60 seconds...")
            time.sleep(60)
        
        # Improved prompt for beautiful, minimal images without text
        prompt = f"""Create a visually beautiful, minimalist image related to '{title_en}'. 
{prompt_addition}
Make the image aesthetically pleasing with clean composition and elegant lighting.
The image should have a modern, premium feel with a focus on simplicity and beauty.
DO NOT include any text, words, labels, or numbers in the image.
Focus on creating a single, powerful visual with minimal elements that elegantly represents the subject."""
        
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
                        file_name = f"assets/nonfiction_images/{story_id}"
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
    generate() 