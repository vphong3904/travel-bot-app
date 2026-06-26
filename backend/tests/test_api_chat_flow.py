"""
Integration test cho route /chat/sessions/{id}/messages (POST).

Đây là phần CHECKLIST_TONG_THE.md mục 4 đánh dấu "⬜ Chưa thấy" — "Test
tích hợp API (vd: gọi /chat, kiểm tra response shape)".

Chiến lược: KHÔNG dựng Postgres/MongoDB/Qdrant/Gemini thật. Lý do:
  - ChatMessage.sources dùng kiểu JSONB của riêng PostgreSQL dialect
    (sqlalchemy.dialects.postgresql.JSONB) — không tương thích thẳng với
    SQLite, nên "DB test nhẹ" kiểu SQLite in-memory sẽ cần thêm lớp tương
    thích phức tạp, rủi ro che giấu bug thật ở chỗ khác.
  - RAGPipeline thật cần sentence-transformers + qdrant-client +
    google-genai (model nặng, gọi API thật, tốn phí, không hợp với CI).

Thay vào đó, test theo đúng triết lý "integration test ở tầng route":
  - Dùng FastAPI TestClient/ASGITransport gọi thật vào `app` (đi qua toàn
    bộ middleware, routing, validation Pydantic của FastAPI — đây là phần
    quan trọng nhất cần integration-test, không phải logic DB).
  - Override 2 dependency `get_db` và `get_current_user` bằng fake/mock
    đơn giản (không cần DB thật).
  - Patch `app.api.routes.chat_messages.get_rag` để trả về RAG giả với
    `.query()` mock sẵn — kiểm tra route xử lý đúng response shape mà
    RAGPipeline thật trả ra, KHÔNG kiểm tra logic RAG (đã có
    test_hallucination_guard.py / test_hybrid_search.py / nlp test riêng).

Yêu cầu: pip install -r requirements.txt -r requirements-test.txt
Chạy: pytest backend/tests/test_api_chat_flow.py -v

LƯU Ý: conftest.py đã set JWT_SECRET_KEY/GEMINI_API_KEY giả trước khi
import app — nếu máy bạn không có file backend/.env, test vẫn import được.

⚠️ MINH BẠCH: File test này được viết bằng cách đọc kỹ source code thật
(route, model, schema, dependency) nhưng KHÔNG được chạy thử trên môi
trường có sẵn FastAPI/SQLAlchemy thật (môi trường soạn file này không có
kết nối mạng để cài dependency). Nhiều khả năng chạy đúng ngay từ lần đầu,
nhưng nếu gặp lỗi nhỏ khi chạy thật (vd: khác phiên bản SQLAlchemy/httpx
khiến `stmt.froms` hoặc cách ASGITransport xử lý exception khác đi), đó là
lỗi cần sửa ở chính file test này, không phải dấu hiệu code app có bug.
Hãy chạy `pytest -v` và đọc traceback cụ thể nếu có lỗi.
"""

from __future__ import annotations

import sys
import uuid
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from pathlib import Path
from types import SimpleNamespace
from uuid import uuid4

import pytest
from httpx import ASGITransport, AsyncClient

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.main import app  # noqa: E402
from app.api.deps import get_db, get_current_user  # noqa: E402
from app.db.models.chat import ChatSession  # noqa: E402
from app.db.models.user import User  # noqa: E402
import app.api.routes.chat_messages as chat_messages_module  # noqa: E402
from app.services import log_service  # noqa: E402


FAKE_USER_ID = str(uuid4())
FAKE_SESSION_ID = str(uuid4())


def _make_fake_user() -> User:
    # Dùng uuid.UUID object thật cho id, giống hành vi thật của
    # get_current_user() ở deps.py (decode JWT -> UUID(user_id) -> query DB
    # -> trả về User với id là UUID object, không phải string thô).
    user = User(
        id=uuid.UUID(FAKE_USER_ID),
        username="test_user",
        email="test_user@example.com",
        full_name="Test User",
        role="user",
        is_active=True,
        is_deleted=False,
    )
    return user


class FakeAsyncSession:
    """
    Giả lập tối thiểu AsyncSession cho đúng những gì route
    chat_messages.send_message() thật sự dùng: execute() (để
    _assert_session_owner + _get_recent_history select), add(), flush(),
    commit(), refresh().

    Không dùng SQLAlchemy thật — vì route chỉ cần các method này được gọi
    đúng tuần tự, không cần một DB engine thật chạy phía sau.
    """

    def __init__(self, session_row: ChatSession | None, history_rows: list | None = None):
        self._session_row = session_row
        self._history_rows = history_rows or []
        self.added: list = []
        self.committed = False

    async def execute(self, stmt):
        # _assert_session_owner: select(ChatSession.id)... -> scalar_one_or_none()
        # _get_recent_history: select(ChatMessage.role, ChatMessage.content)... -> .all()
        # Phân biệt 2 case dựa trên tên bảng thật trong .froms — đây là
        # thuộc tính ổn định của mọi sqlalchemy.sql.Select, không phụ
        # thuộc cách compile chuỗi SQL hay format nội bộ ở từng phiên bản.
        table_names = {t.name for t in stmt.froms}

        if "chat_sessions" in table_names:
            return SimpleNamespace(
                scalar_one_or_none=lambda: (self._session_row.id if self._session_row else None)
            )
        return SimpleNamespace(all=lambda: list(self._history_rows))

    def add(self, obj):
        self.added.append(obj)

    async def flush(self):
        pass

    async def commit(self):
        self.committed = True

    async def refresh(self, obj):
        if not getattr(obj, "created_at", None):
            obj.created_at = datetime.now(timezone.utc)


class FakeRAGPipeline:
    """RAGPipeline giả — không gọi Gemini/Qdrant thật."""

    def __init__(self, response: dict | None = None, raise_exc: Exception | None = None):
        self._response = response or {
            "answer": "Đà Lạt mát mẻ quanh năm, nhiệt độ trung bình 18-23 độ C.",
            "sources": [{"title": "Đà Lạt - Khí hậu", "score": 0.78}],
            "intent": "ask_weather",
            "prompt_tokens": 120,
            "completion_tokens": 40,
            "latency_ms": 850,
        }
        self._raise_exc = raise_exc
        self.last_call_kwargs: dict | None = None

    async def query(self, question: str, history: list[dict], session_id: str) -> dict:
        self.last_call_kwargs = {
            "question": question,
            "history": history,
            "session_id": session_id,
        }
        if self._raise_exc:
            raise self._raise_exc
        return self._response


@pytest.fixture(autouse=True)
def _reset_rag_singleton():
    """chat_messages.py cache RAGPipeline trong biến module-level `_rag`.
    Reset giữa các test để tránh 1 test ảnh hưởng test khác."""
    chat_messages_module._rag = None
    yield
    chat_messages_module._rag = None


@pytest.fixture
def fake_session_row() -> ChatSession:
    return ChatSession(
        id=FAKE_SESSION_ID,
        user_id=FAKE_USER_ID,
        title="Hỏi về Đà Lạt",
        model_name="gemini-2.0-flash",
        is_deleted=False,
    )


@pytest.fixture
def override_auth_and_db(fake_session_row):
    """Override get_current_user + get_db, KHÔNG đụng tới DB thật.
    Trả về FakeAsyncSession để test có thể kiểm tra .added / .committed."""
    fake_user = _make_fake_user()
    fake_db = FakeAsyncSession(session_row=fake_session_row)

    async def _fake_get_current_user():
        return fake_user

    async def _fake_get_db():
        yield fake_db

    app.dependency_overrides[get_current_user] = _fake_get_current_user
    app.dependency_overrides[get_db] = _fake_get_db

    yield fake_db

    app.dependency_overrides.pop(get_current_user, None)
    app.dependency_overrides.pop(get_db, None)


@asynccontextmanager
async def _client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        yield client


# ════════════════════════════════════════════════════════════════════════════
# Tests
# ════════════════════════════════════════════════════════════════════════════

class TestSendMessageHappyPath:
    async def test_returns_201_with_expected_shape(
        self, monkeypatch, override_auth_and_db
    ):
        fake_rag = FakeRAGPipeline()
        monkeypatch.setattr(chat_messages_module, "get_rag", lambda: fake_rag)

        # Patch log_service.log_behavior để không phải kết nối MongoDB thật.
        called = {}

        async def _fake_log_behavior(**kwargs):
            called.update(kwargs)
            return {}

        monkeypatch.setattr(log_service, "log_behavior", _fake_log_behavior)

        async with _client() as client:
            resp = await client.post(
                f"/api/chat/sessions/{FAKE_SESSION_ID}/messages",
                json={"content": "Thời tiết Đà Lạt thế nào?"},
                headers={"Authorization": "Bearer fake-token-not-checked-due-to-override"},
            )

        assert resp.status_code == 201
        body = resp.json()
        assert body["role"] == "assistant"
        assert body["content"] == fake_rag._response["answer"]
        assert body["intent"] == "ask_weather"
        assert body["sources"] == fake_rag._response["sources"]
        assert body["prompt_tokens"] == 120
        assert body["completion_tokens"] == 40

        # Behavior log phải được ghi với đúng event_type "ask_chatbot"
        assert called.get("event_type") == "ask_chatbot"
        assert called.get("user_id") == FAKE_USER_ID

    async def test_rag_receives_question_and_session_id(
        self, monkeypatch, override_auth_and_db
    ):
        fake_rag = FakeRAGPipeline()
        monkeypatch.setattr(chat_messages_module, "get_rag", lambda: fake_rag)

        async def _fake_log_behavior(**kwargs):
            return {}

        monkeypatch.setattr(log_service, "log_behavior", _fake_log_behavior)

        async with _client() as client:
            await client.post(
                f"/api/chat/sessions/{FAKE_SESSION_ID}/messages",
                json={"content": "Đi Sa Pa tháng nào đẹp?"},
                headers={"Authorization": "Bearer fake-token"},
            )

        assert fake_rag.last_call_kwargs is not None
        assert fake_rag.last_call_kwargs["session_id"] == FAKE_SESSION_ID
        # NLP rewriting có thể biến đổi câu hỏi gốc — chỉ assert nó không rỗng
        assert len(fake_rag.last_call_kwargs["question"]) > 0


class TestSendMessageErrorCases:
    async def test_session_not_owned_by_user_returns_404(
        self, monkeypatch, override_auth_and_db
    ):
        """_assert_session_owner phải chặn truy cập session của người khác."""
        fake_db = override_auth_and_db
        fake_db._session_row = None  # mô phỏng session không thuộc user này

        fake_rag = FakeRAGPipeline()
        monkeypatch.setattr(chat_messages_module, "get_rag", lambda: fake_rag)

        async with _client() as client:
            resp = await client.post(
                f"/api/chat/sessions/{FAKE_SESSION_ID}/messages",
                json={"content": "Xin chào"},
                headers={"Authorization": "Bearer fake-token"},
            )

        assert resp.status_code == 404
        # RAG không được gọi nếu chặn ở bước xác thực quyền sở hữu session
        assert fake_rag.last_call_kwargs is None

    async def test_missing_auth_header_returns_401_or_403(self):
        """Không override auth — gọi thẳng route phải bị chặn bởi HTTPBearer
        (auto_error=True) vì thiếu Authorization header."""
        async with _client() as client:
            resp = await client.post(
                f"/api/chat/sessions/{FAKE_SESSION_ID}/messages",
                json={"content": "Xin chào"},
            )
        # FastAPI HTTPBearer(auto_error=True) trả 403 khi thiếu header
        assert resp.status_code in (401, 403)

    async def test_empty_content_returns_422_validation_error(
        self, override_auth_and_db
    ):
        """ChatMessageCreate.content có min_length=1 — content rỗng phải
        bị Pydantic chặn trước khi vào route."""
        async with _client() as client:
            resp = await client.post(
                f"/api/chat/sessions/{FAKE_SESSION_ID}/messages",
                json={"content": ""},
                headers={"Authorization": "Bearer fake-token"},
            )
        assert resp.status_code == 422

    async def test_content_too_long_returns_422(self, override_auth_and_db):
        """max_length=4000 — vượt quá phải bị chặn ở tầng validation."""
        async with _client() as client:
            resp = await client.post(
                f"/api/chat/sessions/{FAKE_SESSION_ID}/messages",
                json={"content": "a" * 4001},
                headers={"Authorization": "Bearer fake-token"},
            )
        assert resp.status_code == 422

    async def test_rag_exception_propagates_as_500(
        self, monkeypatch, override_auth_and_db
    ):
        """Nếu RAGPipeline raise lỗi không bắt được (vd: bug thật ngoài
        phạm vi try/except nội bộ của rag.query), route không nên "nuốt"
        lỗi âm thầm — phải biểu hiện ra ngoài thành lỗi rõ ràng để dev biết
        mà sửa, không phải trả 200 với answer rỗng.

        Starlette's ServerErrorMiddleware (luôn bật trừ khi debug=True)
        thường convert exception chưa bắt thành response 500. Một số
        phiên bản/cấu hình httpx ASGITransport có thể để exception lan
        thẳng ra ngoài thay vì thành response — test chấp nhận cả 2,
        miễn là KHÔNG bao giờ là 200 (đó mới là việc thật sự không được
        phép xảy ra: trả lời "thành công" trong khi RAG thật sự đã lỗi)."""
        fake_rag = FakeRAGPipeline(raise_exc=RuntimeError("Gemini API lỗi giả lập"))
        monkeypatch.setattr(chat_messages_module, "get_rag", lambda: fake_rag)

        async with _client() as client:
            try:
                resp = await client.post(
                    f"/api/chat/sessions/{FAKE_SESSION_ID}/messages",
                    json={"content": "Xin chào"},
                    headers={"Authorization": "Bearer fake-token"},
                )
            except RuntimeError as exc:
                # Exception lan thẳng ra ngoài transport — vẫn là hành vi
                # đúng (không nuốt lỗi thành công), chỉ khác cách biểu hiện.
                assert "Gemini API lỗi giả lập" in str(exc)
                return

        assert resp.status_code >= 500


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
