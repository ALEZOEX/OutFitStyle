#!/usr/bin/env python3
"""
Script to import Kaggle Fashion Product Images dataset into our database
"""

import pandas as pd
import sqlite3
import os
from pathlib import Path

def map_category(master_category, sub_category, article_type):
    """Map Kaggle categories to our categories"""
    # Our categories: outerwear, upper, lower, footwear, accessories
    if 'shoes' in article_type.lower() or 'footwear' in article_type.lower():
        return 'footwear'
    elif 'top' in article_type.lower() or 'shirt' in article_type.lower() or 'blouse' in article_type.lower():
        return 'upper'
    elif 'jeans' in article_type.lower() or 'trouser' in article_type.lower() or 'pants' in article_type.lower():
        return 'lower'
    elif 'jacket' in article_type.lower() or 'coat' in article_type.lower() or 'sweatshirt' in article_type.lower():
        return 'outerwear'
    elif 'accessories' in master_category.lower() or 'scarf' in article_type.lower() or 'hat' in article_type.lower():
        return 'accessories'
    else:
        # Default to upper for tops
        return 'upper'

def map_warmth_level(season, base_colour):
    """Map season to warmth level (1-10)"""
    if season in ['Winter', 'Fall']:
        return 8
    elif season in ['Summer']:
        return 3
    elif season in ['Spring']:
        return 5
    else:
        return 6  # Default

def map_formality_level(article_type):
    """Map article type to formality level (1-10)"""
    formal_items = ['suit', 'blazer', 'dress', 'shirt']
    casual_items = ['t-shirt', 'jeans', 'shorts', 'sneakers']
    
    article_lower = article_type.lower()
    if any(item in article_lower for item in formal_items):
        return 8
    elif any(item in article_lower for item in casual_items):
        return 3
    else:
        return 5  # Default

def get_emoji_for_category(category):
    """Get emoji for category"""
    emojis = {
        'outerwear': '🧥',
        'upper': '👕',
        'lower': '👖',
        'footwear': '👟',
        'accessories': '🧣'
    }
    return emojis.get(category, '👗')

def import_kaggle_data(csv_path, db_path):
    """Import Kaggle fashion data into our database"""
    # Read the CSV file
    df = pd.read_csv(csv_path)
    
    # Connect to database
    conn = sqlite3.connect(db_path)
    
    # Process each row
    imported_count = 0
    for _, row in df.iterrows():
        try:
            # Extract data
            name = row.get('productDisplayName', f"Item {row['id']}")
            master_category = row.get('masterCategory', '')
            sub_category = row.get('subCategory', '')
            article_type = row.get('articleType', '')
            base_colour = row.get('baseColour', '')
            season = row.get('season', '')
            gender = row.get('gender', '')
            
            # Map to our categories
            category = map_category(master_category, sub_category, article_type)
            warmth_level = map_warmth_level(season, base_colour)
            formality_level = map_formality_level(article_type)
            emoji = get_emoji_for_category(category)
            
            # Insert into database
            cursor = conn.cursor()
            cursor.execute("""
                INSERT OR IGNORE INTO clothing_items 
                (name, category, subcategory, min_temp, max_temp, 
                 weather_conditions, style, warmth_level, formality_level, icon_emoji)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                name,
                category,
                article_type,
                5 if warmth_level < 5 else 15,  # Approximate min_temp
                25 if warmth_level < 5 else 35,  # Approximate max_temp
                '["clear","clouds"]',  # Default weather conditions
                'casual',  # Default style
                warmth_level,
                formality_level,
                emoji
            ))
            
            imported_count += 1
            if imported_count % 1000 == 0:
                print(f"Imported {imported_count} items...")
                conn.commit()
                
        except Exception as e:
            print(f"Error processing item {row.get('id', 'unknown')}: {e}")
            continue
    
    conn.commit()
    conn.close()
    print(f"Successfully imported {imported_count} items from Kaggle dataset")

if __name__ == "__main__":
    # Paths - adjust these to your actual paths
    csv_path = "path/to/fashion-product-images/styles.csv"
    db_path = "path/to/outfitstyle/server/database/outfitstyle.db"
    
    if not os.path.exists(csv_path):
        print(f"CSV file not found: {csv_path}")
        print("Please download the Kaggle Fashion Product Images dataset and update the path")
        exit(1)
        
    if not os.path.exists(db_path):
        print(f"Database not found: {db_path}")
        print("Please ensure the database exists")
        exit(1)
    
    import_kaggle_data(csv_path, db_path)