"""Xử lý ảnh upload chung (resize + convert WebP) — dùng cho media manager (admin)
và avatar (user)."""
from typing import Optional


def process_image(
    content: bytes, ext: str, max_side: int = 1920
) -> tuple[bytes, str, Optional[str], Optional[int], Optional[int]]:
    """Resize ảnh về tối đa `max_side` px (cạnh dài nhất) + convert WebP nếu có Pillow.
    Lỗi/không có Pillow → giữ nguyên nội dung gốc."""
    try:
        import io
        from PIL import Image

        img = Image.open(io.BytesIO(content))
        if img.mode not in ("RGB", "RGBA", "L"):
            img = img.convert("RGBA")
        w, h = img.size
        if max(w, h) > max_side:
            ratio = max_side / float(max(w, h))
            img = img.resize((max(1, int(w * ratio)), max(1, int(h * ratio))))
        buf = io.BytesIO()
        img.save(buf, format="WEBP", quality=82, method=4)
        out = buf.getvalue()
        return out, "webp", "image/webp", img.size[0], img.size[1]
    except Exception:
        return content, ext, None, None, None
