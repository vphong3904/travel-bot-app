import logging
import os
import sys

def get_logger(name: str = "app"):
    """
    Tạo logger chuẩn cho toàn bộ ứng dụng.
    - In ra console (stdout)
    - Format: [LEVEL] timestamp module: message
    - Mức log đọc từ biến môi trường LOG_LEVEL (mặc định: INFO)
      Ví dụ: LOG_LEVEL=DEBUG docker compose up
    """
    logger = logging.getLogger(name)
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        formatter = logging.Formatter(
            "[%(levelname)s] %(asctime)s %(name)s: %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S"
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        log_level = os.getenv("LOG_LEVEL", "INFO").upper()
        logger.setLevel(getattr(logging, log_level, logging.INFO))
    return logger
