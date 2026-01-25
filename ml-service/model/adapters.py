from typing import Any, Dict


def normalize_item(raw: Dict[str, Any]) -> Dict[str, Any]:
    d = dict(raw)

    # поля разных контрактов -> единые
    if "warmth_level" not in d and "warmth" in d:
        d["warmth_level"] = d["warmth"]
    if "formality_level" not in d and "formality" in d:
        d["formality_level"] = d["formality"]

    if "item_style" not in d and "style" in d:
        d["item_style"] = d["style"]

    if "item_name" not in d:
        d["item_name"] = d.get("name", "")

    # дефолты
    d.setdefault("category", "upper")
    d.setdefault("subcategory", "")
    d.setdefault("gender", "unisex")
    d.setdefault("base_colour", "black")
    d.setdefault("pattern", "solid")
    d.setdefault("fit", "regular")
    d.setdefault("source", "synthetic")
    d.setdefault("source_priority", 0)
    d.setdefault("is_owned", False)

    # нормализация строк
    for k in ["category", "subcategory", "gender", "item_style", "base_colour", "pattern", "fit", "source"]:
        if isinstance(d.get(k), str):
            d[k] = d[k].strip().lower()

    return d
