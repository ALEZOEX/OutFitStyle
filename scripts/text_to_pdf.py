import os
from fpdf import FPDF
from pathlib import Path

def create_pdf_from_text(text_file_path, pdf_file_path):
    """Create a PDF file from a text file."""

    # Initialize PDF object
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    # Using the default core font but handling special characters
    
    # Read the text file
    with open(text_file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Replace special characters that cause encoding issues
    content = content.replace('═', '=').replace('█', '#').replace('▬', '-').replace('►', '>').replace('•', '*')

    # Split content into lines
    lines = content.split('\n')
    
    # Add title page
    pdf.add_page()
    pdf.set_font('helvetica', 'B', size=16)
    pdf.cell(200, 10, "OutfitStyle Client Code Collection", new_x="LMARGIN", new_y="NEXT", align='C')
    pdf.ln(10)
    pdf.set_font('helvetica', size=12)
    pdf.cell(200, 10, f"Total file size: {os.path.getsize(text_file_path)} bytes", new_x="LMARGIN", new_y="NEXT", align='C')
    pdf.ln(20)
    pdf.set_font('helvetica', size=8)
    pdf.cell(200, 10, "This document contains all client-side code files combined into a single document.", new_x="LMARGIN", new_y="NEXT", align='L')
    pdf.ln(10)

    # Add content pages
    for line in lines:
        # Replace special characters that cause encoding issues
        clean_line = line.replace('═', '=').replace('█', '#').replace('▬', '-')

        # Handle long lines by wrapping them
        if len(clean_line) > 110:  # If line is too long for the page
            # Split the line into chunks
            while len(clean_line) > 110:
                pdf.cell(200, 4, clean_line[:110], new_x="LMARGIN", new_y="NEXT")
                clean_line = clean_line[110:]

        # Add remaining part of the line
        if clean_line:
            pdf.cell(200, 4, clean_line, new_x="LMARGIN", new_y="NEXT")
    
    # Save the PDF
    pdf.output(pdf_file_path)
    print(f"PDF file created successfully: {pdf_file_path}")

if __name__ == "__main__":
    text_file = "D:/outfitstyle/client_files.txt"
    pdf_file = "D:/outfitstyle/client_code.pdf"
    create_pdf_from_text(text_file, pdf_file)