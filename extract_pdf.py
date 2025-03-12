import PyPDF2
import re

def extract_text_from_pdf(pdf_path):
    """Extract text from a PDF file with improved formatting"""
    try:
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            num_pages = len(reader.pages)
            print(f"PDF has {num_pages} pages")
            
            full_text = ""
            for page_num in range(num_pages):
                page = reader.pages[page_num]
                text = page.extract_text()
                
                # Clean up excessive whitespace
                text = re.sub(r'\s+', ' ', text)
                
                full_text += f"\n--- Page {page_num + 1} ---\n{text}\n"
            
            return full_text
    except Exception as e:
        print(f"Error: {str(e)}")
        return None

# Path to your PDF file
pdf_file = "MSA Fiction Stories (3).pdf"

# Extract text
text = extract_text_from_pdf(pdf_file)

# Save to a text file
if text:
    output_file = "improved_extracted_text.txt"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(text)
    print(f"Text saved to {output_file}")
    
    # Print a preview
    preview_length = 500
    preview = text[:preview_length] + "..." if len(text) > preview_length else text
    print("\nPreview of extracted text:")
    print(preview) 