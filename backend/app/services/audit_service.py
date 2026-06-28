"""
Audit Log Service — ghi lại mọi thao tác admin vào MongoDB.

Cách dùng:
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="update",
        resource_type="knowledge_entry",
        resource_id=str(entry_id),
        before_value=before_dict,
        after_value=after_dict,
        request=request,  # optional, để lấy IP + user_agent
    )
"""

import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import Request

from app.db.mongo import COLLECTION_AUDIT_LOGS
from app.db.models.user import User


VALID_ACTIONS = frozenset({
    "create", "update", "delete",
    "login", "logout", "login_failed",
    "role_change", "config_change",
    "embed_trigger", "promote_to_kb",
})

VALID_RESOURCE_TYPES = frozenset({
    "knowledge_entry", "user", "chat_session",
    "system_config", "content", "media",
    "intent_pattern", "city_mapping", "notification",
})


async def log_audit(
    mongo_db,
    actor: User,
    action: str,
    resource_type: str,
    resource_id: str = "",
    before_value: dict[str, Any] | None = None,
    after_value: dict[str, Any] | None = None,
    request: Request | None = None,
    extra: dict[str, Any] | None = None,
) -> str:
    """
    Ghi 1 audit log entry vào MongoDB.

    Returns: id của document vừa tạo (string ObjectId).
    """
    ip_address = ""
    user_agent = ""

    if request:
        forwarded_for = request.headers.get("X-Forwarded-For")
        ip_address = (
            forwarded_for.split(",")[0].strip()
            if forwarded_for
            else str(request.client.host)
        )
        user_agent = request.headers.get("User-Agent", "")

    doc = {
        "id": str(uuid.uuid4()),
        "actor_id": str(actor.id),
        "actor_email": actor.email,
        "actor_role": actor.role,
        "action": action,
        "resource_type": resource_type,
        "resource_id": resource_id,
        "before_value": before_value,
        "after_value": after_value,
        "ip_address": ip_address,
        "user_agent": user_agent,
        "extra": extra or {},
        "created_at": datetime.now(timezone.utc),
    }

    result = await mongo_db[COLLECTION_AUDIT_LOGS].insert_one(doc)
    return str(result.inserted_id)


def model_to_audit_dict(obj) -> dict:
    """
    Convert SQLAlchemy model instance thành dict để lưu vào before/after_value.
    Tự động loại trừ các field nhạy cảm.
    """
    EXCLUDE_FIELDS = {"password_hash", "hashed_password"}

    if hasattr(obj, "__dict__"):
        return {
            k: str(v) if not isinstance(v, (str, int, float, bool, type(None))) else v
            for k, v in obj.__dict__.items()
            if not k.startswith("_") and k not in EXCLUDE_FIELDS
        }
    return {}
