import os
import mimetypes
import time
from google import genai
from google.genai import types

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
    
    # Leonardo da Vinci image details
    story_id = "leonardo-da-vinci-the-renaissance-man"
    title_en = "Leonardo da Vinci, The Renaissance Man"
    
    print(f"Regenerating image for: {title_en}")
    
    # Simplified prompt for Leonardo da Vinci image
    prompt = """Create a visually beautiful, minimalist image for 'Leonardo da Vinci, The Renaissance Man'.
A simple, elegant image featuring a clean, minimal sketch inspired by da Vinci's work - such as a wing design or a simple mechanical drawing.
Use soft, Renaissance-style lighting with a warm color palette.
The composition should be clean and uncluttered with focus on a single element.
DO NOT include any text, words, labels, or numbers in the image.
Create a visually striking but minimal image that elegantly represents da Vinci's genius through simplicity."""
    
    # Retry logic
    max_retries = 5
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
                break
                
            # If no image was generated, retry
            print(f"No image generated for {title_en}, retrying with a modified prompt...")
            # Slightly modify prompt with each retry to overcome potential issues
            prompt = prompt + f" Attempt {attempt+2}."
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