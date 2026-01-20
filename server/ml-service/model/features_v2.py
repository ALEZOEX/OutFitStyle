from typing import Any, Dict, List
import pandas as pd

_WEATHER_MAP = {
    "ясно": "clear",
    "облачно": "clouds",
    "дождь": "rain",
    "морось": "drizzle",
    "снег": "snow",
    "туман": "mist",
    "гроза": "thunderstorm",
}

def _season_from_temp(t: float) -> str:
    if t < 0:
        return "winter"
    if t < 12:
        return "autumn"
    if t < 22:
        return "spring"
    return "summer"


def build_feature_frame_v2(
    weather_data: Dict[str, Any],
    user_profile: Dict[str, Any],
    items: List[Dict[str, Any]],
) -> pd.DataFrame:
    temp = float(weather_data.get("temperature", 20.0))
    feels_like = float(weather_data.get("feels_like", temp))

    wc = weather_data.get("weather") or weather_data.get("weather_condition") or "clear"
    if isinstance(wc, str):
        wc_l = wc.strip().lower()
        wc = _WEATHER_MAP.get(wc_l, wc_l)

    season = weather_data.get("season") or _season_from_temp(temp)
    if isinstance(season, str):
        season = season.strip().lower()

    base = {
        "temperature": temp,
        "feels_like": feels_like,
        "humidity": float(weather_data.get("humidity", 50)),
        "wind_speed": float(weather_data.get("wind_speed", 0)),
        "weather_condition": wc,
        "season": season,
        "age_range": str(user_profile.get("age_range", "25-35")),
        "style_preference": str(user_profile.get("style_preference", "casual")).strip().lower(),
        "temperature_sensitivity": str(user_profile.get("temperature_sensitivity", "normal")).strip().lower(),
        "formality_preference": str(user_profile.get("formality_preference", "casual")).strip().lower(),
        "user_gender": str(user_profile.get("gender", "unisex")).strip().lower(),
    }

    rows = []
    for it in items:
        rows.append({
            **base,
            "item_name": it.get("item_name", ""),
            "category": it.get("category", "upper"),
            "subcategory": it.get("subcategory", ""),
            "gender": it.get("gender", "unisex"),
            "min_temp": float(it.get("min_temp", 0)),
            "max_temp": float(it.get("max_temp", 30)),
            "warmth_level": float(it.get("warmth_level", 5)),
            "formality_level": float(it.get("formality_level", 3)),
            "item_style": str(it.get("item_style", "casual")).strip().lower(),
            "base_colour": str(it.get("base_colour", "black")).strip().lower(),
            "pattern": str(it.get("pattern", "solid")).strip().lower(),
            "fit": str(it.get("fit", "regular")).strip().lower(),
            "source": str(it.get("source", "synthetic")).strip().lower(),
            "source_priority": float(it.get("source_priority", 0)),
            "is_owned": 1.0 if bool(it.get("is_owned", False)) else 0.0,
        })

    return pd.DataFrame(rows)
