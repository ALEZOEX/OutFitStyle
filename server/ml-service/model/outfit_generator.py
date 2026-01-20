from dataclasses import dataclass
from typing import Any, Dict, List, Tuple
import numpy as np


ALLOWED_CATS = {"outerwear", "upper", "lower", "footwear", "accessory"}

NEUTRAL_COLORS = {"black", "white", "gray", "grey", "beige", "navy", "brown"}
STYLE_GROUPS = {
    "business": "smart",
    "formal": "smart",
    "classic": "smart",
    "smart_casual": "smart",
    "elegant": "smart",
    "casual": "casual",
    "street": "casual",
    "sport": "sport",
    "outdoor": "sport",
}

@dataclass
class Outfit:
    items: Dict[str, Dict[str, Any]]     # category -> item dict
    outfit_score: float
    breakdown: Dict[str, float]


def _style_group(s: str) -> str:
    s = (s or "casual").lower()
    return STYLE_GROUPS.get(s, s)


def _style_coherence(items: List[Dict[str, Any]], user_style: str) -> float:
    gs = [_style_group(it.get("item_style")) for it in items]
    user_g = _style_group(user_style)
    if not gs:
        return 0.5
    major = max(set(gs), key=gs.count)
    match_major = sum(g == major for g in gs) / len(gs)
    match_user = sum(g == user_g for g in gs) / len(gs)
    return 0.5 * match_major + 0.5 * match_user


def _formality_consistency(items: List[Dict[str, Any]]) -> float:
    vals = [float(it.get("formality_level", 3)) for it in items]
    if not vals:
        return 0.5
    spread = max(vals) - min(vals)
    return max(0.0, 1.0 - spread / 4.0)  # spread=0 =>1, spread>=4 =>0


def _color_harmony(items: List[Dict[str, Any]]) -> float:
    colors = [(it.get("base_colour") or "").lower() for it in items]
    colors = [c for c in colors if c]
    if not colors:
        return 0.5
    non_neutral = [c for c in colors if c not in NEUTRAL_COLORS]
    if len(non_neutral) == 0:
        return 1.0
    if len(set(non_neutral)) == 1:
        return 0.8
    if len(set(non_neutral)) == 2:
        return 0.55
    return 0.3


def _weather_fit(items: List[Dict[str, Any]], temperature: float) -> float:
    ok = 0
    for it in items:
        mn = float(it.get("min_temp", -100))
        mx = float(it.get("max_temp", 100))
        if mn <= temperature <= mx:
            ok += 1
    return ok / max(1, len(items))


def _outfit_score(items: List[Dict[str, Any]], item_scores: List[float], user_style: str, temperature: float) -> Tuple[float, Dict[str, float]]:
    base = float(np.mean(item_scores)) if item_scores else 0.0
    sc = _style_coherence(items, user_style)
    fc = _formality_consistency(items)
    ch = _color_harmony(items)
    wf = _weather_fit(items, temperature)

    score = 0.60 * base + 0.15 * sc + 0.10 * fc + 0.10 * ch + 0.05 * wf
    return score, {
        "base": base,
        "style_coherence": sc,
        "formality_consistency": fc,
        "color_harmony": ch,
        "weather_fit": wf,
    }


def generate_outfits(
    candidates: List[Dict[str, Any]],
    scores_by_id: Dict[Any, float],
    temperature: float,
    user_style: str,
    k: int = 5,
    topn_per_category: int = 20,
    beam_size: int = 60,
) -> List[Outfit]:
    # группируем по категориям
    by_cat: Dict[str, List[Dict[str, Any]]] = {}
    for it in candidates:
        cat = (it.get("category") or "upper").lower()
        if cat not in ALLOWED_CATS:
            continue
        by_cat.setdefault(cat, []).append(it)

    # topN по item_score
    for cat in by_cat:
        by_cat[cat].sort(key=lambda x: scores_by_id.get(x.get("id"), 0.0), reverse=True)
        by_cat[cat] = by_cat[cat][:topn_per_category]

    # обязательные категории
    required = ["upper", "lower", "footwear"]
    optional = []
    if temperature < 10 and "outerwear" in by_cat:
        optional.append("outerwear")
    if "accessory" in by_cat:
        optional.append("accessory")

    cats = [c for c in required if c in by_cat] + [c for c in optional if c in by_cat]
    if not cats:
        return []

    # beam search по категориям
    beams: List[Dict[str, Dict[str, Any]]] = [dict()]
    for cat in cats:
        pool = by_cat.get(cat, [])
        if not pool:
            continue
        next_beams = []
        for partial in beams:
            used = {v.get("id") for v in partial.values()}
            for it in pool:
                if it.get("id") in used:
                    continue
                nm = dict(partial)
                nm[cat] = it
                next_beams.append(nm)

        def partial_score(m):
            vals = [scores_by_id.get(v.get("id"), 0.0) for v in m.values()]
            return float(np.mean(vals)) if vals else 0.0

        next_beams.sort(key=partial_score, reverse=True)
        beams = next_beams[:beam_size]
        if not beams:
            break

    # финальный скор + простая диверсификация
    scored: List[Outfit] = []
    for m in beams:
        items = list(m.values())
        item_scores = [scores_by_id.get(x.get("id"), 0.0) for x in items]
        s, br = _outfit_score(items, item_scores, user_style=user_style, temperature=temperature)
        scored.append(Outfit(items=m, outfit_score=s, breakdown=br))

    scored.sort(key=lambda o: o.outfit_score, reverse=True)

    result: List[Outfit] = []
    used_ids = set()
    for o in scored:
        ids = {v.get("id") for v in o.items.values()}
        if len(ids & used_ids) >= 2:  # не даём почти одинаковые outfits
            continue
        result.append(o)
        used_ids |= ids
        if len(result) >= k:
            break

    return result
