import os
import mimetypes
import time
from google import genai
from google.genai import types

# List of specific images to regenerate with the user's specific vision prompts
SELECTED_IMAGES = [
    {
        "id": "leonardo-da-vinci-the-renaissance-man", 
        "title_en": "Leonardo da Vinci, The Renaissance Man", 
        "prompt": "Create a beautifully lit, cinematic image of an empty artist's seat in front of a blank canvas. Include some renaissance-era art tools - perhaps brushes, paints, and a palette - arranged neatly nearby. The scene should be in a minimalist studio with soft, natural light coming through a window. No people should be present, just the empty seat, blank canvas, and art tools, creating a sense of anticipation. Use a warm, renaissance color palette. No text should appear in the image."
    },
    
    {
        "id": "cleopatra-the-last-pharaoh", 
        "title_en": "Cleopatra, The Last Pharaoh", 
        "prompt": "Create a breathtaking, cinematic landscape view of the Egyptian pyramids at sunset or sunrise. The image should look like a high-quality shot from a major film production - with perfect golden hour lighting, dramatic shadows, and rich colors. The pyramids should be majestic against the colorful sky, perhaps with some sand dunes in the foreground. No people or text should be present in the image. Focus on creating a stunning, movie-quality landscape that captures the epic beauty of ancient Egypt."
    },
    
    {
        "id": "a-journey-through-the-seven-wonders", 
        "title_en": "A Journey Through the Seven Wonders", 
        "prompt": "Create a stunning, cinematic shot of Easter Island (Rapa Nui) Moai statues at either sunrise or sunset. The image should have the quality of a professional travel documentary or film, with perfect lighting, dramatic shadows, and rich colors. Focus on the iconic stone faces with their distinctive silhouettes against a dramatic sky. No people or text should be in the image. Capture the mystery and majesty of these ancient monuments through expert cinematography techniques - low angle, golden hour lighting, and perfect composition."
    },
    
    {
        "id": "resilience-in-the-face-of-adversity", 
        "title_en": "Resilience in the Face of Adversity", 
        "prompt": "Create a single, beautiful landscape image that's split exactly in half: one side showing a bright, sunny scene with vibrant colors, blue skies, and flourishing nature; the other side showing the exact same landscape but during a storm with rain, darker colors, and more dramatic lighting. The contrast should be striking but the transition seamless - as if it's the same place in two different conditions. No people or text should appear in the image. Use expert composition and lighting to symbolize resilience through this visual metaphor of a landscape enduring different conditions."
    },
    
    {
        "id": "the-silk-road-rediscovered", 
        "title_en": "The Silk Road Rediscovered", 
        "prompt": "Create a cinematic image of an ancient road or path that appears to be covered with a long, flowing piece of richly colored silk fabric. The silk should run along the center of the path, creating a beautiful contrast with the surrounding landscape. Use dramatic lighting like golden hour sunlight to highlight the texture and sheen of the silk. The road might wind through a desert, mountain pass, or other landscape that evokes the historical Silk Road. No people or text should appear in the image. Focus on creating a visually stunning scene with perfect lighting and composition."
    }
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
    print(f"Regenerating {len(SELECTED_IMAGES)} images with specific vision prompts")
    
    for story in SELECTED_IMAGES:
        story_id = story['id']
        title_en = story['title_en']
        specific_prompt = story['prompt']
        
        print(f"Generating image for: {title_en}")
        
        # Rate limit management - pause every 3 requests
        request_count += 1
        if request_count > 1 and request_count % 3 == 0:
            print("Approaching rate limit, pausing for 60 seconds...")
            time.sleep(60)
        
        # Retry logic
        max_retries = 3
        for attempt in range(max_retries):
            try:
                contents = [
                    types.Content(
                        role="user",
                        parts=[
                            types.Part.from_text(text=specific_prompt),
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