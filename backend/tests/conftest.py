"""
conftest.py dùng chung cho toàn bộ test backend.

Vấn đề cần giải quyết: app/core/config.py định nghĩa JWT_SECRET_KEY và
GEMINI_API_KEY KHÔNG có giá trị default (bắt buộc phải có trong .env hoặc
biến môi trường) — nên bất kỳ test nào `import app...` (trực tiếp hoặc
gián tiếp qua main.py / rag_pipeline.py / deps.py) sẽ crash ngay từ lúc
import nếu môi trường CI/máy lạ không có file backend/.env thật.

Set các biến môi trường GIẢ (không phải secret thật của project) ở đây,
trước khi bất kỳ module nào trong app/ được import, để:
  - Test chạy được trên máy CI / máy đồng đội không có sẵn .env thật.
  - Không bao giờ cần commit secret thật (JWT_SECRET_KEY, GEMINI_API_KEY)
    vào repo chỉ để test chạy được.

Các test gọi API thật (Gemini, Qdrant, Postgres, Mongo) phải tự skip hoặc
mock — conftest này KHÔNG đảm bảo các service đó có chạy thật, chỉ đảm bảo
việc `import app.*` không bị raise lỗi validation ngay từ đầu.
"""

import os

_FAKE_ENV_DEFAULTS = {
    "JWT_SECRET_KEY": "test-only-fake-secret-key-not-for-production",
    "GEMINI_API_KEY": "test-only-fake-gemini-key",
    # DATABASE_URL/MONGODB_URL/QDRANT_URL đã có default trong Settings,
    # nhưng đặt lại rõ ràng ở đây để test integration (nếu chạy thật) không
    # vô tình nối nhầm vào DB thật của ai đó khi chạy local.
    "DATABASE_URL": "postgresql+asyncpg://user:12345678@localhost:5432/pdtrip_ai_db_test",
    "MONGODB_URL": "mongodb://localhost:27017",
    "MONGODB_DB_NAME": "pdtrip_ai_logs_test",
}

for _key, _value in _FAKE_ENV_DEFAULTS.items():
    os.environ.setdefault(_key, _value)
