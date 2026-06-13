"""
websocket_manager.py
────────────────────
Quản lý WebSocket connections để đồng bộ chat real-time.

Luồng hoạt động:
  1. Flutter kết nối WS: ws://<host>/api/chat/ws/{user_id}
  2. Flutter gửi JSON: {"message": "...", "user_name": "..."}
  3. Backend xử lý (intent → RAG → Gemini) rồi push kết quả về qua WS
  4. Flutter nhận JSON ChatResponse và render lên UI
"""

from __future__ import annotations

import asyncio
import logging
from typing import Dict, Set

from fastapi import WebSocket

logger = logging.getLogger(__name__)


class ConnectionManager:
    """
    Quản lý pool các WebSocket connection theo user_id.
    Một user_id có thể mở nhiều tab/thiết bị → dùng Set[WebSocket].
    """

    def __init__(self) -> None:
        # {user_id: {websocket, ...}}
        self._connections: Dict[str, Set[WebSocket]] = {}

    # ── Lifecycle ──────────────────────────────────────────────────────────────

    async def connect(self, websocket: WebSocket, user_id: str | int) -> None:
        await websocket.accept()
        key = str(user_id)
        self._connections.setdefault(key, set()).add(websocket)
        logger.info("WS connected  user=%s  total_sockets=%d", key, len(self._connections[key]))

    def disconnect(self, websocket: WebSocket, user_id: str | int) -> None:
        key = str(user_id)
        sockets = self._connections.get(key, set())
        sockets.discard(websocket)
        if not sockets:
            self._connections.pop(key, None)
        logger.info("WS disconnected user=%s  remaining=%d", key, len(sockets))

    # ── Gửi tin nhắn ──────────────────────────────────────────────────────────

    async def send_to_user(self, user_id: str | int, data: dict) -> None:
        """Gửi dict JSON tới tất cả socket của một user."""
        key = str(user_id)
        dead: list[WebSocket] = []
        for ws in list(self._connections.get(key, [])):
            try:
                await ws.send_json(data)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(ws, user_id)

    async def broadcast(self, data: dict) -> None:
        """Broadcast tới toàn bộ users (dùng cho admin push notification)."""
        tasks = [
            self.send_to_user(uid, data)
            for uid in list(self._connections.keys())
        ]
        await asyncio.gather(*tasks, return_exceptions=True)

    # ── Tiện ích ──────────────────────────────────────────────────────────────

    @property
    def active_users(self) -> list[str]:
        return list(self._connections.keys())

    def count(self) -> int:
        return sum(len(v) for v in self._connections.values())


# Singleton — import và dùng trực tiếp trong router
manager = ConnectionManager()