# contracts/event_contract.py
from typing import Optional, Dict, Any, Literal
from pydantic import BaseModel, Field


class ActionEvent(BaseModel):
    request_id: str = Field(..., description="request_id из заголовка X-Request-Id (или из TZ request_id)")
    user_id: str = Field(default="anonymous")
    action_type: str = Field(..., description="click/add_to_outfit/wear/purchase/like/etc")
    entity_type: Literal["item", "outfit"] = "item"
    entity_id: str = Field(..., description="item_id или outfit_id")
    meta: Optional[Dict[str, Any]] = None


class ActionEventResponse(BaseModel):
    ok: bool = True