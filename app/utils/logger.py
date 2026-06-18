import logging
import sys

def get_logger(name: str = "app"):
    """
    Tạo logger chuẩn cho toàn bộ ứng dụng.
    - In ra console
    - Format: [LEVEL] timestamp module: message
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
        logger.setLevel(logging.INFO)
    return logger
