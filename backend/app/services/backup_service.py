"""
Backup Database — pg_dump qua container Docker (xem docker-compose.yml).

Dự án chạy Postgres trong container `travel_postgres` (không cài pg_dump trên
host), nên backup được thực hiện bằng `docker exec ... pg_dump` rồi ghi output
ra file `.sql` trong thư mục backups/ ở gốc repo.
"""

import asyncio
from datetime import datetime
from pathlib import Path

from app.utils import get_logger

logger = get_logger("backup")

# backend/app/services/backup_service.py -> parents[2] = backend/ -> parent = repo root
BACKUP_DIR = Path(__file__).resolve().parents[2].parent / "backups"

DB_CONTAINER = "travel_postgres"
DB_USER = "user"
DB_NAME = "pdtrip_ai_db"


async def create_backup() -> Path:
    """Chạy pg_dump trong container, ghi kết quả ra backups/<db>_<timestamp>.sql."""
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filepath = BACKUP_DIR / f"{DB_NAME}_{timestamp}.sql"

    proc = await asyncio.create_subprocess_exec(
        "docker", "exec", DB_CONTAINER, "pg_dump", "-U", DB_USER, "-d", DB_NAME,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await proc.communicate()
    if proc.returncode != 0:
        raise RuntimeError(f"pg_dump thất bại: {stderr.decode(errors='ignore')}")

    filepath.write_bytes(stdout)
    logger.info(f"[Backup] Đã tạo backup {filepath.name} ({len(stdout)} bytes)")
    return filepath


def list_backups() -> list[dict]:
    if not BACKUP_DIR.exists():
        return []
    files = sorted(
        BACKUP_DIR.glob(f"{DB_NAME}_*.sql"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    return [
        {
            "filename": f.name,
            "size_bytes": f.stat().st_size,
            "created_at": datetime.fromtimestamp(f.stat().st_mtime).isoformat(),
        }
        for f in files
    ]


async def run_scheduled_backup() -> None:
    """Job gọi bởi APScheduler lúc 00:00 hằng ngày — lỗi chỉ log, không crash app."""
    try:
        await create_backup()
    except Exception as e:
        logger.error(f"[Backup] Auto backup 00:00 thất bại: {e}", exc_info=True)
