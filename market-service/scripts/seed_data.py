"""
Seed script for populating the market database with test products.
"""
import asyncio
import random
import uuid
from decimal import Decimal
from typing import List

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

from db.models import Base, Product, ProductCategory


# ═══════════════════════════════════════════
# SEED DATA
# ═══════════════════════════════════════════

BRANDS = ["Nike", "Adidas", "Zara", "H&M", "Uniqlo", "Puma", "Reebok", "Levi's", "Gap", "Massimo Dutti"]

STYLE_TAGS = ["casual", "sport", "classic", "streetwear", "minimalist", "vintage", "elegant", "urban"]

SIZES = ["XS", "S", "M", "L", "XL", "XXL"]

COLORS = ["black", "white", "gray", "navy", "beige", "brown", "green", "blue", "red", "pink"]

PRODUCT_NAMES = {
    ProductCategory.TOP: [
        "Basic T-Shirt", "Cotton Polo", "Casual Shirt", "Slim Fit Tee", "Oversized Hoodie",
        "Crew Neck Sweater", "V-Neck Top", "Long Sleeve Tee", "Tank Top", "Henley Shirt",
        "Graphic Tee", "Striped Shirt", "Linen Shirt", "Denim Shirt", "Flannel Shirt",
    ],
    ProductCategory.BOTTOM: [
        "Classic Jeans", "Slim Chinos", "Cargo Pants", "Joggers", "Shorts",
        "Linen Trousers", "Dress Pants", "Skinny Jeans", "Wide Leg Pants", "Corduroy Pants",
        "Track Pants", "Bermuda Shorts", "Pleated Trousers", "Straight Jeans", "Tapered Pants",
    ],
    ProductCategory.SHOES: [
        "Running Sneakers", "Classic White Sneakers", "Leather Boots", "Canvas Shoes", "Loafers",
        "High-Top Sneakers", "Slip-On Shoes", "Hiking Boots", "Oxford Shoes", "Desert Boots",
        "Trail Running Shoes", "Minimalist Sneakers", "Chelsea Boots", "Espadrilles", "Sandals",
    ],
    ProductCategory.OUTERWEAR: [
        "Bomber Jacket", "Denim Jacket", "Leather Jacket", "Parka", "Trench Coat",
        "Puffer Jacket", "Wool Coat", "Windbreaker", "Hoodie Jacket", "Blazer",
        "Rain Jacket", "Peacoat", "Cardigan", "Vest", "Track Jacket",
    ],
    ProductCategory.ACCESSORIES: [
        "Leather Belt", "Canvas Backpack", "Baseball Cap", "Beanie", "Scarf",
        "Sunglasses", "Watch", "Wallet", "Gloves", "Tie",
        "Bow Tie", "Suspenders", "Hair Band", "Headband", "Bandana",
    ],
    ProductCategory.HEADWEAR: [
        "Baseball Cap", "Beanie", "Bucket Hat", "Fedora", "Panama Hat",
        "Beret", "Flat Cap", "Snapback", "Trucker Hat", "Winter Hat",
    ],
}

DESCRIPTIONS = {
    ProductCategory.TOP: "Comfortable and stylish top for everyday wear. Made from premium materials.",
    ProductCategory.BOTTOM: "Versatile bottoms perfect for any occasion. Great fit and durability.",
    ProductCategory.SHOES: "Premium footwear combining comfort and style. Perfect for daily wear.",
    ProductCategory.OUTERWEAR: "Stylish outerwear to keep you warm and looking great.",
    ProductCategory.ACCESSORIES: "Essential accessories to complete your look.",
    ProductCategory.HEADWEAR: "Trendy headwear for sun protection and style.",
}


def generate_products(count: int = 300) -> List[Product]:
    """Generate test products."""
    products = []
    categories = list(ProductCategory)
    
    for i in range(count):
        category = random.choice(categories)
        brand = random.choice(BRANDS)
        name = random.choice(PRODUCT_NAMES[category])
        
        # Generate unique product name
        full_name = f"{brand} {name} #{i + 1}"
        
        # Price based on category
        base_prices = {
            ProductCategory.TOP: (1500, 8000),
            ProductCategory.BOTTOM: (2000, 12000),
            ProductCategory.SHOES: (3000, 20000),
            ProductCategory.OUTERWEAR: (5000, 30000),
            ProductCategory.ACCESSORIES: (500, 5000),
            ProductCategory.HEADWEAR: (800, 4000),
        }
        min_price, max_price = base_prices[category]
        price = Decimal(str(random.randint(min_price, max_price)))
        
        # Random attributes
        num_sizes = random.randint(3, 6)
        num_colors = random.randint(2, 5)
        num_styles = random.randint(1, 3)
        
        product = Product(
            id=uuid.uuid4(),
            name=full_name,
            description=f"{DESCRIPTIONS[category]} Perfect for {random.choice(['casual', 'sport', 'work', 'weekend'])} wear.",
            brand=brand,
            category=category,
            subcategory=f"{category.value}_{random.randint(1, 5)}",
            price=price,
            currency="RUB",
            image_urls=[
                f"https://example.com/images/{category.value}/{i + 1}_1.jpg",
                f"https://example.com/images/{category.value}/{i + 1}_2.jpg",
            ],
            sizes=random.sample(SIZES, num_sizes),
            colors=random.sample(COLORS, num_colors),
            style_tags=random.sample(STYLE_TAGS, num_styles),
            in_stock=random.random() > 0.1,  # 90% in stock
            stock_count=random.randint(0, 100),
        )
        products.append(product)
    
    return products


async def seed_database():
    """Seed the database with test products."""
    # Database URL - adjust as needed
    database_url = "postgresql+asyncpg://postgres:password@localhost:5432/market"
    
    engine = create_async_engine(database_url, echo=True)
    async_session = async_sessionmaker(engine, class_=AsyncSession)
    
    try:
        # Create tables
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        
        print("Tables created successfully")
        
        # Generate products
        products = generate_products(300)
        print(f"Generated {len(products)} products")
        
        # Insert products
        async with async_session() as session:
            session.add_all(products)
            await session.commit()
        
        print(f"Successfully inserted {len(products)} products into the database")
        
        # Print summary
        async with async_session() as session:
            from sqlalchemy import select, func
            
            result = await session.execute(
                select(Product.category, func.count(Product.id))
                .group_by(Product.category)
            )
            
            print("\nProducts by category:")
            for row in result:
                print(f"  {row[0].value}: {row[1]}")
    
    except Exception as e:
        print(f"Error seeding database: {e}")
        raise
    finally:
        await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed_database())
