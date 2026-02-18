# Getting Started with OutfitStyle

## Overview

OutfitStyle is a clothing recommendation application based on weather, personal preferences, and user wardrobe. The project implements an advanced architecture with a unified clothing catalog and a multi-level recommendation system.

### Key Features
- Integration with Weather API for real-time data
- ML model for personalized recommendations
- Google Sign In support
- Password recovery
- Personalized outfit recommendations

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Git
- API keys for external services (OpenWeatherMap, Google OAuth)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-org/outfitstyle.git
cd outfitstyle
```

2. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Start the services**
```bash
docker-compose -f docker-compose.dev.yml up -d
```

4. **Verify the installation**
```bash
curl http://localhost:8080/health
```

## Architecture Overview

### Unified Clothing Model

All clothing items are stored in a single `clothing_items` table with extended attributes:
- `gender` - gender (Men, Women, Unisex, Boys, Girls)
- `master_category` - main category (Apparel, Accessory, Footwear, etc.)
- `subcategory` - subcategory (Tshirts, Jeans, Dresses, etc.)
- `season` - season (Spring, Summer, Fall, Winter)
- `base_colour` - base color
- `usage` - usage (Casual, Formal, Sports, etc.)
- `source` - source (wardrobe, catalog, kaggle_seed, marketplace)
- `is_owned` - whether the item belongs to the user
- `owner_user_id` - owner ID (for personal items)

### Data Source Priorities

1. **Personal wardrobe (wardrobe)** - user's items if they match the weather
2. **Real new items (catalog/marketplace)** - actual products
3. **Kaggle seed** - "sample" items from the dataset for training

## Next Steps

- [Architecture Overview](../02-architecture/detailed.md)
- [API Reference](../03-api/reference.md)
- [Development Guide](../04-development/guide.md)
- [Deployment Guide](../05-deployment/guide.md)
