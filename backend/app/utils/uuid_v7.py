import os
import time
import uuid

def uuid_v7() -> uuid.UUID:
    """
    Sinh UUID v7 (time-ordered) tương tự hàm trong PostgreSQL.
    - timestamp (millis) + random bytes
    - Giúp index trong DB hiệu quả hơn UUID v4
    """
    # Lấy timestamp (milliseconds)
    ts_ms = int(time.time() * 1000)

    # 48-bit timestamp (6 bytes)
    ts_bytes = ts_ms.to_bytes(6, byteorder="big")

    # Random 10 bytes
    rand_bytes = os.urandom(10)

    # Ghép lại thành 16 bytes
    raw = ts_bytes + rand_bytes

    # Set version (7) và variant (RFC 4122)
    raw = bytearray(raw)
    raw[6] = (raw[6] & 0x0F) | 0x70  # version 7
    raw[8] = (raw[8] & 0x3F) | 0x80  # variant 10xx

    return uuid.UUID(bytes=bytes(raw))

