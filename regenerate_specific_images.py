import os
import mimetypes
import time
from google import genai
from google.genai import types

# List of specific images to regenerate with specific prompt additions
FICTION_IMAGES = [
    {"id": "the-goblins-gold", "title_en": "The Goblin's Gold", "prompt_addition": "A stunning image of glittering gold coins cascading through mysterious, gnarled hands in a dimly lit cave with crystal formations."},
    {"id": "the-gravity-anomaly", "title_en": "The Gravity Anomaly", "prompt_addition": "A breathtaking visual of objects suspended in midair around a glowing singularity, with stunning light effects and rich colors."},
    {"id": "neural-drift-programmer", "title_en": "Neural Drift Programmer", "prompt_addition": "A captivating image of neural networks visualized as glowing blue pathways intertwining with computer code elements in a dramatic composition."},
    {"id": "the-final-spark", "title_en": "The Final Spark", "prompt_addition": "A beautiful close-up of a single electric spark against darkness, with dramatic lighting and electric blue tones spreading outward."},
    {"id": "the-phantom-passenger", "title_en": "The Phantom Passenger", "prompt_addition": "A hauntingly beautiful vintage train car interior with ethereal mist and dramatic lighting creating the sense of a ghostly presence."},
    {"id": "the-grinning-portrait", "title_en": "The Grinning Portrait", "prompt_addition": "An elegant antique portrait frame with mysterious shadows creating an uncanny atmosphere, with rich textures and dramatic lighting."},
    {"id": "the-forgotten-song", "title_en": "The Forgotten Song", "prompt_addition": "A visually striking vintage gramophone with musical notes visualized as wisps of golden light in a dusty attic setting."},
    {"id": "the-midnight-visitor", "title_en": "The Midnight Visitor", "prompt_addition": "A captivating moonlit window with curtains gently billowing, creating mysterious shadows in a beautiful night scene."},
    {"id": "the-starlight-beacon", "title_en": "The Starlight Beacon", "prompt_addition": "A breathtaking lighthouse beam cutting through a star-filled night sky, with dramatic ocean waves and cosmic elements."}
]

NONFICTION_IMAGES = [
    {"id": "cleopatra-the-last-pharaoh", "title_en": "Cleopatra, The Last Pharaoh", "prompt_addition": "A stunning product-shot style image of the Egyptian pyramids at sunset with a golden royal scarab beetle in the foreground and the silhouette of a regal female figure."},
    {"id": "leonardo-da-vinci-the-renaissance-man", "title_en": "Leonardo da Vinci, The Renaissance Man", "prompt_addition": "A beautiful composition showing the Vitruvian Man sketch alongside a perfectly rendered flying machine blueprint with Renaissance-style lighting."},
    {"id": "elizabeth-i-the-virgin-queen", "title_en": "Elizabeth I, The Virgin Queen", "prompt_addition": "A breathtaking product-shot of the Tudor crown with deep red velvet and pearls, with dramatic lighting on a royal purple background."},
    {"id": "malcolm-x-the-activists-journey", "title_en": "Malcolm X, The Activist's Journey", "prompt_addition": "A powerful image of iconic black-rimmed glasses resting on a powerful speech page, with dramatic lighting and civil rights movement symbols."},
    {"id": "the-gratitude-journal", "title_en": "The Gratitude Journal", "prompt_addition": "A visually stunning composition of an elegant leather-bound journal with a fountain pen, surrounded by symbolic elements like flower petals and warm sunlight."},
    {"id": "overcoming-procrastination", "title_en": "Overcoming Procrastination", "prompt_addition": "A captivating image of an hourglass with sand transforming into productive symbols like completed tasks and achievements, with beautiful lighting effects."},
    {"id": "setting-smart-goals", "title_en": "Setting Smart Goals", "prompt_addition": "A beautiful composition showing a mountain summit with stepping stones leading upward, with rich colors and dramatic lighting."},
    {"id": "the-growth-mindset", "title_en": "The Growth Mindset", "prompt_addition": "A visually stunning image of a tree growing from a brain-shaped root system, with vibrant colors and dynamic composition."},
    {"id": "resilience-in-the-face-of-adversity", "title_en": "Resilience in the Face of Adversity", "prompt_addition": "A powerful image of a bamboo stalk bending but not breaking in a storm, with dramatic lighting and a beautiful composition."},
    {"id": "the-industrial-revolution", "title_en": "The Industrial Revolution", "prompt_addition": "A breathtaking image of vintage steam engines and gears in motion with dramatic lighting and copper/brass tones, styled like a high-end product shot."},
    {"id": "a-journey-through-the-seven-wonders", "title_en": "A Journey Through the Seven Wonders", "prompt_addition": "A stunning composite image showing elements of all seven wonders in a beautiful arrangement, with dramatic lighting like a travel magazine cover."},
    {"id": "road-trip-across-america", "title_en": "Road Trip Across America", "prompt_addition": "A captivating image of a vintage convertible on a stunning desert highway with iconic American landscapes and a beautiful sunset."},
    {"id": "deserts-of-the-world", "title_en": "Deserts of the World", "prompt_addition": "A breathtaking sand dune with perfect ripples, dramatic lighting and rich golden colors, shot like a premium landscape photograph."},
    {"id": "the-silk-road-rediscovered", "title_en": "The Silk Road Rediscovered", "prompt_addition": "A beautiful composition of silk fabrics, spices and ancient artifacts arranged in a stunning still life with dramatic lighting."},
    {"id": "the-mystery-of-the-black-dahlia", "title_en": "The Mystery of the Black Dahlia", "prompt_addition": "A haunting image of a black dahlia flower with water droplets, dramatic film noir lighting and mysterious shadow elements."},
    {"id": "the-green-river-killer", "title_en": "The Green River Killer", "prompt_addition": "A moody, atmospheric image of a winding green river through a misty forest with dramatic lighting and subtle thriller elements."},
    {"id": "earths-greatest-extinctions", "title_en": "Earth's Greatest Extinctions", "prompt_addition": "A powerful image showing dinosaur fossils dramatically lit against volcanic activity in the background, museum-quality presentation."},
    {"id": "the-zodiac-killer", "title_en": "The Zodiac Killer", "prompt_addition": "A dramatic close-up of vintage cipher symbols and a magnifying glass with film noir lighting and atmospheric shadow elements."}
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
    os.makedirs("assets/story_images", exist_ok=True)
    os.makedirs("assets/nonfiction_images", exist_ok=True)
    
    # Process count for rate limit management
    request_count = 0
    
    # Process fiction stories
    print(f"Regenerating {len(FICTION_IMAGES)} fiction story images")
    
    for story in FICTION_IMAGES:
        story_id = story['id']
        title_en = story['title_en']
        prompt_addition = story['prompt_addition']
        
        print(f"Generating image for: {title_en}")
        
        # Rate limit management - pause every 9 requests
        request_count += 1
        if request_count > 1 and request_count % 9 == 0:
            print("Approaching rate limit, pausing for 60 seconds...")
            time.sleep(60)
        
        # Improved prompt for more captivating, symbolic images without text
        prompt = f"""Create a visually captivating, professionally-photographed image related to '{title_en}'. 
{prompt_addition}
Make the image visually striking with professional lighting and composition.
The image should look like it belongs in a high-end magazine or photography collection.
DO NOT include any text, words, labels, or numbers in the image.
Focus on creating a single, powerful visual that symbolizes the theme."""
        
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
    
    # Process nonfiction stories
    print(f"Regenerating {len(NONFICTION_IMAGES)} nonfiction story images")
    
    for story in NONFICTION_IMAGES:
        story_id = story['id']
        title_en = story['title_en']
        prompt_addition = story['prompt_addition']
        
        print(f"Generating image for: {title_en}")
        
        # Rate limit management - pause every 9 requests
        request_count += 1
        if request_count > 1 and request_count % 9 == 0:
            print("Approaching rate limit, pausing for 60 seconds...")
            time.sleep(60)
        
        # Improved prompt for more captivating, symbolic images without text
        prompt = f"""Create a visually captivating, professionally-photographed image related to '{title_en}'. 
{prompt_addition}
Make the image visually stunning with professional lighting and composition.
The image should look like it belongs in a high-end magazine, textbook, or photography collection.
DO NOT include any text, words, labels, or numbers in the image.
Focus on creating a single, powerful visual that clearly represents the subject."""
        
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