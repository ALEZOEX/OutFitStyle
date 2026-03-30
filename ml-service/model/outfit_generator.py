from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Set, Tuple
import logging

logger = logging.getLogger(__name__)


def _safe_float(val: Any, default: float) -> float:
    """Безопасное преобразование в float с обработкой None"""
    if val is None:
        return default
    try:
        return float(val)
    except (TypeError, ValueError):
        return default


ALLOWED_CATS = {"outerwear", "upper", "lower", "footwear", "accessory"}

NEUTRAL_COLORS = {"black", "white", "gray", "beige", "navy", "brown"}
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


def _style_group(s: Optional[str]) -> str:
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
    vals = [_safe_float(it.get("formality_level"), 3.0) for it in items]
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
    """
    Проверка соответствия одежды температуре.
    Возвращает долю предметов, подходящих для данной температуры.
    Допуск ±2°C для смягчения фильтрации.
    """
    ok = 0
    tolerance = 2.0
    for it in items:
        mn = _safe_float(it.get("min_temp"), -100.0) - tolerance
        mx = _safe_float(it.get("max_temp"), 100.0) + tolerance
        if mn <= temperature <= mx:
            ok += 1
    return ok / max(1, len(items))


def _outfit_score(items: List[Dict[str, Any]], item_scores: List[float], user_style: str, temperature: float) -> Tuple[float, Dict[str, float]]:
    """
    Расчёт скоринга аутфита.
    
    Weather fit используется как множитель-штраг: если одежда не подходит погоде,
    общий скоринг значительно снижается.
    """
    base = sum(item_scores) / len(item_scores) if item_scores else 0.0
    sc = _style_coherence(items, user_style)
    fc = _formality_consistency(items)
    ch = _color_harmony(items)
    wf = _weather_fit(items, temperature)

    # Базовый скоринг
    score = 0.60 * base + 0.15 * sc + 0.10 * fc + 0.10 * ch
    
    # Weather fit как штрафной множитель (не слагаемое!)
    # Если wf < 0.5, значит больше половины предметов не подходят погоде
    if wf < 0.5:
        score *= (wf * 2)  # сильный штраф
    else:
        score *= (0.5 + wf)  # небольшой бонус за соответствие
    
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
    """
    Генерация аутфитов с помощью beam search.
    
    Args:
        candidates: Список кандидатов-предметов
        scores_by_id: Словарь {item_id: score}
        temperature: Температура воздуха (для подбора по погоде)
        user_style: Предпочтения пользователя
        k: Количество аутфитов для возврата
        topn_per_category: Максимум предметов на категорию
        beam_size: Размер луча для beam search
    
    Returns:
        Список аутфитов, отсортированный по скорингу
    """
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
    
    # Верхняя одежда обязательна при температуре ниже 0°C
    if "outerwear" in by_cat:
        if temperature < 0:
            required.append("outerwear")
        elif temperature < 10:
            optional.append("outerwear")
    
    if "accessory" in by_cat:
        optional.append("accessory")

    # Проверяем наличие всех обязательных категорий
    missing_required = [cat for cat in required if cat not in by_cat or not by_cat[cat]]
    if missing_required:
        logger.warning("Missing required categories: %s — switching to survival mode", missing_required)
        # Survival mode: убираем недостающие из required, добавляем любые доступные
        required = [cat for cat in required if cat not in missing_required]
        available_optional = [cat for cat in ALLOWED_CATS if cat in by_cat and cat not in required]
        required.extend(available_optional[:len(missing_required)])
        optional = [cat for cat in optional if cat in by_cat and cat not in required]

    cats = [c for c in required if c in by_cat] + [c for c in optional if c in by_cat]
    if not cats:
        logger.warning("No categories available for outfit generation")
        return []

    # beam search по категориям
    beams: List[Dict[str, Dict[str, Any]]] = [dict()]
    for cat in cats:
        pool = by_cat.get(cat, [])
        if not pool:
            logger.warning("No items in category %s", cat)
            continue
        next_beams = []
        for partial in beams:
            used = {v.get("id") for v in partial.values() if v.get("id") is not None}
            for it in pool:
                it_id = it.get("id")
                if it_id is None or it_id in used:
                    continue
                nm = dict(partial)
                nm[cat] = it
                next_beams.append(nm)

        def partial_score(m):
            vals = [scores_by_id.get(v.get("id"), 0.0) for v in m.values() if v.get("id") is not None]
            return sum(vals) / len(vals) if vals else 0.0

        next_beams.sort(key=partial_score, reverse=True)
        beams = next_beams[:beam_size]
        if not beams:
            logger.warning("Beam search terminated at category %s - no valid combinations", cat)
            break

    logger.info("Beam search completed: %d beams, generating %d outfits", len(beams), k)

    # финальный скоринг + диверсификация (попарное сравнение)
    scored: List[Outfit] = []
    for m in beams:
        items = list(m.values())
        item_scores = [scores_by_id.get(x.get("id"), 0.0) for x in items if x.get("id") is not None]
        s, br = _outfit_score(items, item_scores, user_style=user_style, temperature=temperature)
        scored.append(Outfit(items=m, outfit_score=s, breakdown=br))

    scored.sort(key=lambda o: o.outfit_score, reverse=True)

    # Динамическая диверсификация: чем меньше гардероб, тем мягче ограничение
    total_candidates = sum(len(items) for items in by_cat.values())
    if total_candidates < 15:
        max_shared = len(cats)  # малый гардероб: разрешаем любые пересечения
    elif total_candidates < 30:
        max_shared = len(cats) - 1  # средний: минимум 1 уникальная вещь
    else:
        max_shared = 1  # большой гардероб: максимум 1 общая вещь

    # Диверсификация: сравниваем каждый аутфит с уже выбранными попарно
    result: List[Outfit] = []
    selected_ids: List[Set[str]] = []
    for o in scored:
        ids: Set[str] = {v["id"] for v in o.items.values() if v.get("id") is not None}

        # Проверяем пересечение с каждым уже выбранным аутфитом
        is_duplicate = False
        for prev_ids in selected_ids:
            if len(ids & prev_ids) > max_shared:
                is_duplicate = True
                break
        
        if is_duplicate:
            continue
            
        result.append(o)
        selected_ids.append(ids)
        if len(result) >= k:
            break

    logger.info("Generated %d outfits (requested %d)", len(result), k)
    return result
