import PyPDF2
import re
import os

def extract_text_from_pdf(pdf_path, output_path=None):
    """
    Extract text from a PDF file with improved formatting and organization
    
    Args:
        pdf_path (str): Path to the PDF file
        output_path (str, optional): Path to save the extracted text
        
    Returns:
        str: Extracted and formatted text
    """
    try:
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            num_pages = len(reader.pages)
            print(f"PDF has {num_pages} pages")
            
            full_text = ""
            current_section = ""
            
            for page_num in range(num_pages):
                page = reader.pages[page_num]
                text = page.extract_text()
                
                # Clean up excessive whitespace
                text = re.sub(r'\s+', ' ', text)
                
                # Add page separator
                full_text += f"\n\n--- Page {page_num + 1} ---\n\n"
                full_text += text + "\n"
                
                # Try to identify section headers for better organization
                section_matches = re.findall(r'(Fiction \([^)]+\)|اﻟﻣﺳﺗوى [^(]+\(.*Level\))', text)
                if section_matches:
                    for match in section_matches:
                        current_section = match.strip()
                        full_text += f"\n[Section: {current_section}]\n"
            
            # Save to file if output path is provided
            if output_path:
                with open(output_path, 'w', encoding='utf-8') as out_file:
                    out_file.write(full_text)
                print(f"Text saved to '{output_path}'")
            
            return full_text
    
    except Exception as e:
        print(f"Error extracting text: {str(e)}")
        return None

def create_structured_output(pdf_path, output_dir="extracted_stories"):
    """
    Create a more structured output with separate files for different sections
    
    Args:
        pdf_path (str): Path to the PDF file
        output_dir (str): Directory to save the extracted stories
    """
    try:
        # Create output directory if it doesn't exist
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        # Extract all text first
        all_text = extract_text_from_pdf(pdf_path)
        
        # Save the complete text
        with open(os.path.join(output_dir, "complete_text.txt"), 'w', encoding='utf-8') as f:
            f.write(all_text)
        
        # Try to split by genres and levels
        genres = ["Fantasy", "Science Fiction", "Mystery", "Adventure", "Horror", "Drama"]
        levels = ["Beginner", "Intermediate", "Advanced"]
        
        # Create a summary file
        with open(os.path.join(output_dir, "summary.txt"), 'w', encoding='utf-8') as summary_file:
            summary_file.write("MSA Fiction Stories - Summary\n\n")
            
            for genre in genres:
                genre_pattern = f"Fiction \\({genre}\\)"
                if re.search(genre_pattern, all_text, re.IGNORECASE):
                    summary_file.write(f"Genre: {genre}\n")
                    
                    # Extract stories for this genre
                    genre_text = ""
                    in_genre = False
                    for line in all_text.split('\n'):
                        if re.search(genre_pattern, line, re.IGNORECASE):
                            in_genre = True
                            genre_text += f"\n{line}\n"
                        elif in_genre and any(f"Fiction ({other})" in line for other in genres if other != genre):
                            in_genre = False
                        elif in_genre:
                            genre_text += line + "\n"
                    
                    # Save genre-specific text
                    with open(os.path.join(output_dir, f"{genre.replace(' ', '_')}_stories.txt"), 'w', encoding='utf-8') as genre_file:
                        genre_file.write(genre_text)
                    
                    # List stories in this genre
                    story_titles = re.findall(r'(?:Description: |^)([A-Za-z].*?)(?:\n|$)', genre_text, re.MULTILINE)
                    for title in story_titles:
                        if len(title) > 10 and not title.startswith("Fiction"):  # Filter out non-titles
                            summary_file.write(f"  - {title.strip()}\n")
                    
                    summary_file.write("\n")
        
        print(f"Structured output created in '{output_dir}' directory")
        
    except Exception as e:
        print(f"Error creating structured output: {str(e)}")

# Path to your PDF file
pdf_file = "MSA Fiction Stories (3).pdf"

# Extract text with improved formatting
extract_text_from_pdf(pdf_file, "better_formatted_text.txt")

# Create a more structured output
create_structured_output(pdf_file) 