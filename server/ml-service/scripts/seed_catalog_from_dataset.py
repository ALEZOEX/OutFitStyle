import os
import pandas as pd
from sqlalchemy import create_engine, text

DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "outfitstyle")

engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

def map_category(raw_cat: str) -> str:
    raw = (raw_cat or "").lower()
    if raw in ["top", "shirt", "t-shirt", "blouse", "sweatshirt", "knit"]:
        return "upper"
    if raw in ["bottom", "pants", "jeans", "skirt", "shorts"]:
        return "lower"
    if raw in ["jacket", "coat", "jacket_coat", "outerwear"]:
        return "outerwear"
    if raw in ["shoes", "sneakers", "boots"]:
        return "footwear"
    return "upper"

def main():
    df = pd.read_csv("data/season fashion dataset - multilabel.csv")  # пример

    rows = []
    for _, row in df.iterrows():
        name = str(row.get("productDisplayName") or row.get("name") or "").strip()
        if not name:
            continue

        raw_cat = str(row.get("subCategory") or row.get("masterCategory") or "")
        category = map_category(raw_cat)

        # простые дефолты, потом можно улучшить CLIP'ом
        warmth_level = 5.0
        min_temp = 0.0
        max_temp = 25.0
        style = "casual"
        formality_level = "casual"

        rows.append(
            dict(
                user_id=None,           # это «каталог», не личный гардероб
                source="catalog",
                name=name,
                category=category,
                subcategory=raw_cat,
                icon_emoji="👕" if category == "upper" else "👖",
                min_temp=min_temp,
                max_temp=max_temp,
                weather_conditions=None,
                style=style,
                warmth_level=warmth_level,
                formality_level=formality_level,
                wb_search_url=None,
                ozon_search_url=None,
            )
        )

    with engine.begin() as conn:
        for item in rows:
            conn.execute(
                text(
                    """
                    INSERT INTO clothing_items (
                        user_id, name, category, subcategory, icon_emoji,
                        min_temp, max_temp, weather_conditions,
                        style, warmth_level, formality_level
                    )
                    VALUES (
                        :user_id, :name, :category, :subcategory, :icon_emoji,
                        :min_temp, :max_temp, :weather_conditions,
                        :style, :warmth_level, :formality_level
                    )
                    ON CONFLICT DO NOTHING
                    """
                ),
                item,
            )

    print(f"Inserted {len(rows)} catalog items into clothing_items")

if __name__ == "__main__":
    main()