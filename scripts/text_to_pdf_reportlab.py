import os
from reportlab.lib.pagesizes import letter, A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from pathlib import Path

def create_pdf_from_text_reportlab(text_file_path, pdf_file_path):
    """Create a PDF file from a text file using ReportLab."""
    
    # Create the PDF document
    doc = SimpleDocTemplate(
        pdf_file_path,
        pagesize=A4,
        rightMargin=72,
        leftMargin=72,
        topMargin=72,
        bottomMargin=18
    )
    
    # Container for the 'Flowable' objects
    story = []
    
    # Get sample styles and define custom styles
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name='CodeStyle', fontName='Courier', fontSize=8, leading=10))
    styles.add(ParagraphStyle(name='TitleStyle', fontSize=16, alignment=1))  # Centered
    
    # Add title
    title = Paragraph("OutfitStyle Client Code Collection", styles['TitleStyle'])
    story.append(title)
    story.append(Spacer(1, 0.25*inch))

    # Add file size info
    file_size = os.path.getsize(text_file_path)
    size_info = Paragraph(f"Total file size: {file_size} bytes", styles['Normal'])
    story.append(size_info)
    story.append(Spacer(1, 0.25*inch))

    # Add description
    desc = Paragraph("This document contains all client-side code files combined into a single document.", styles['Normal'])
    story.append(desc)
    story.append(Spacer(1, 0.5*inch))
    
    # Read the text file
    with open(text_file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Replace problematic characters
    content = content.replace('<', '&lt;').replace('>', '&gt;')
    
    # Split content into chunks to avoid memory issues
    lines = content.split('\n')
    
    # Process lines in chunks to avoid memory issues
    chunk_size = 50  # Number of lines per chunk
    for i in range(0, len(lines), chunk_size):
        chunk = lines[i:i+chunk_size]
        
        # Join the chunk back into text
        chunk_text = '\n'.join(chunk)
        
        # Create paragraph with code style
        p = Paragraph(chunk_text.replace('&', '&amp;'), styles['CodeStyle'])  # Also escape ampersand
        story.append(p)
        story.append(Spacer(1, 0.1*inch))
    
    # Build the PDF
    doc.build(story)
    print(f"PDF file created successfully: {pdf_file_path}")

if __name__ == "__main__":
    text_file = "D:/outfitstyle/client_files.txt"
    pdf_file = "D:/outfitstyle/client_code.pdf"
    create_pdf_from_text_reportlab(text_file, pdf_file)