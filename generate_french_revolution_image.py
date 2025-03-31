import base64
import os
import mimetypes
import time
from google import genai
from google.genai import types
from dotenv import load_dotenv

def save_binary_file(file_name, data):
    f = open(file_name, "wb")
    f.write(data)
    f.close()

def check_if_image_exists():
    image_id = "the-french-revolution"
    if os.path.exists("assets/nonfiction_images"):
        for file in os.listdir("assets/nonfiction_images"):
            name = os.path.splitext(file)[0]  # Get filename without extension
            if name == image_id:
                print(f"Image for 'The French Revolution' already exists as {file}")
                return True
    return False

def generate_french_revolution_image():
    # Load environment variables from .env file
    load_dotenv()
    
    # First check if image already exists
    if check_if_image_exists():
        print("Image already exists. No need to generate.")
        return
        
    print("Image does not exist. Generating now...")
    
    # Create directory if it doesn't exist
    os.makedirs("assets/nonfiction_images", exist_ok=True)
    
    # Setup Gemini client
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key or api_key == "your_api_key_here":
        print("Error: Please set your GEMINI_API_KEY in the .env file")
        return
        
    client = genai.Client(api_key=api_key)
    model = "gemini-2.0-flash-exp-image-generation"
    
    story_id = "the-french-revolution"
    title_en = "The French Revolution"
    
    # Simplified prompt to just represent France
    prompt = "Create a high-quality thumbnail image representing France. Include iconic French symbols like the Eiffel Tower, tricolor flag, or other recognizable French landmarks. The image should be visually appealing and suitable as a small thumbnail in an educational app. No text in the image."
    
    # Retry logic
    max_retries = 3
    for attempt in range(max_retries):
        try:
            print(f"Attempt {attempt+1}: Generating image representing France")
            
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
                        f"Success! File of mime type {inline_data.mime_type} saved to: {file_name}{file_extension}"
                    )
                    image_generated = True
                else:
                    print(chunk.text)
            
            # If image was generated successfully, break the retry loop
            if image_generated:
                break
                
            # If no image was generated, retry
            print(f"No image generated, retrying...")
            time.sleep(5)  # Wait before retry
            
        except Exception as e:
            error_message = str(e)
            print(f"Error: {error_message}")
            
            # Handle rate limit errors
            if "RESOURCE_EXHAUSTED" in error_message or "429" in error_message:
                retry_delay = 65  # Default 65 seconds
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
    generate_french_revolution_image() 