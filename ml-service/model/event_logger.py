# model/event_logger.py
import os
import json
import threading
from datetime import datetime, timezone
from typing import Any, Dict, Optional

_lock = threading.Lock()


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _get_log_dir() -> str:
    return os.getenv("EVENT_LOG_DIR", "data/logs")


def _enabled() -> bool:
    v = os.getenv("ENABLE_EVENT_LOGGING", "1").strip().lower()
    return v not in {"0", "false", "no", "off"}


def _path(prefix: str) -> str:
    # ежедневная ротация
    day = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    log_dir = _get_log_dir()
    os.makedirs(log_dir, exist_ok=True)
    return os.path.join(log_dir, f"{prefix}_{day}.jsonl")


def log_event(prefix: str, payload: Dict[str, Any]) -> None:
    """Пишем одну строку JSONL. Потокобезопасно."""
    if not _enabled():
        return

    payload = dict(payload)
    payload.setdefault("ts", _utc_now_iso())

    line = json.dumps(payload, ensure_ascii=False)
    p = _path(prefix)

    with _lock:
        with open(p, "a", encoding="utf-8") as f:
            f.write(line + "\n")


def log_rank_impression(
    request_id: str,
    user_id: str,
    api: str,
    model_version: str,
    context: Dict[str, Any],
    candidates: list,
    ranked: list,
    extra: Optional[Dict[str, Any]] = None,
) -> None:
    """
    candidates: список исходных кандидатов (минимум id/category/subcategory/source...)
    ranked: список {id, score, position}
    """
    payload = {
        "event": "impression_rank",
        "request_id": request_id,
        "user_id": user_id,
        "api": api,
        "model_version": model_version,
        "context": context,
        "candidates": candidates,
        "ranked": ranked,
    }
    if extra:
        payload.update(extra)
    log_event("impressions", payload)


def log_outfits_impression(
    request_id: str,
    user_id: str,
    api: str,
    model_version: str,
    context: Dict[str, Any],
    outfits: list,
) -> None:
    """
    outfits: список {outfit_id, outfit_score, position, items:{category->item_id}, breakdown}
    """
    payload = {
        "event": "impression_outfits",
        "request_id": request_id,
        "user_id": user_id,
        "api": api,
        "model_version": model_version,
        "context": context,
        "outfits": outfits,
    }
    log_event("impressions", payload)


def log_action(
    request_id: str,
    user_id: str,
    action_type: str,
    entity_type: str,
    entity_id: str,
    meta: Optional[Dict[str, Any]] = None,
) -> None:
    payload: Dict[str, Any] = {
        "event": "action",
        "request_id": request_id,
        "user_id": user_id,
        "action_type": action_type,   # click/add_to_outfit/wear/purchase/etc
        "entity_type": entity_type,   # item/outfit
        "entity_id": entity_id,
    }
    if meta:
        payload["meta"] = meta
    log_event("actions", payload)