"""
Unit tests cho audit_service — mock MongoDB, không cần service thật.
"""
import pytest
from unittest.mock import AsyncMock, MagicMock
from uuid import uuid4
from datetime import datetime, timezone

from app.db.models.user import User, UserRole
from app.services.audit_service import log_audit, model_to_audit_dict


def _make_user(role: str = UserRole.ADMIN) -> User:
    u = User()
    u.id = uuid4()
    u.email = f"{role}@test.com"
    u.role = role
    return u


def _make_mongo():
    collection = MagicMock()
    insert_result = MagicMock()
    insert_result.inserted_id = "507f1f77bcf86cd799439011"
    collection.insert_one = AsyncMock(return_value=insert_result)
    mongo_db = MagicMock()
    mongo_db.__getitem__ = MagicMock(return_value=collection)
    return mongo_db, collection


@pytest.mark.asyncio
async def test_log_audit_inserts_document():
    mongo_db, collection = _make_mongo()
    actor = _make_user(UserRole.ADMIN)

    result = await log_audit(
        mongo_db=mongo_db,
        actor=actor,
        action="create",
        resource_type="knowledge_entry",
        resource_id="abc-123",
        after_value={"title": "Test"},
    )

    assert collection.insert_one.called
    doc = collection.insert_one.call_args[0][0]
    assert doc["actor_id"] == str(actor.id)
    assert doc["actor_email"] == actor.email
    assert doc["action"] == "create"
    assert doc["resource_type"] == "knowledge_entry"
    assert doc["resource_id"] == "abc-123"
    assert doc["after_value"] == {"title": "Test"}
    assert doc["before_value"] is None
    assert "created_at" in doc


@pytest.mark.asyncio
async def test_log_audit_returns_inserted_id():
    mongo_db, _ = _make_mongo()
    actor = _make_user()
    result = await log_audit(mongo_db=mongo_db, actor=actor, action="delete", resource_type="user")
    assert result == "507f1f77bcf86cd799439011"


@pytest.mark.asyncio
async def test_log_audit_extracts_ip_from_request():
    mongo_db, collection = _make_mongo()
    actor = _make_user()

    request = MagicMock()
    request.headers = {"X-Forwarded-For": "1.2.3.4, 5.6.7.8", "User-Agent": "TestAgent/1.0"}
    request.client = MagicMock(host="127.0.0.1")

    await log_audit(
        mongo_db=mongo_db, actor=actor,
        action="update", resource_type="user",
        request=request,
    )
    doc = collection.insert_one.call_args[0][0]
    assert doc["ip_address"] == "1.2.3.4"
    assert doc["user_agent"] == "TestAgent/1.0"


def test_model_to_audit_dict_excludes_password():
    user = _make_user()
    user.password_hash = "secret_hash"
    result = model_to_audit_dict(user)
    assert "password_hash" not in result
    assert "email" in result
