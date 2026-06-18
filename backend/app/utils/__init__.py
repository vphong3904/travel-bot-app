# __init__.py trong utils
# Gom tất cả tiện ích lại để import dễ dàng

from .logger import get_logger
from .uuid_v7 import uuid_v7
import logging
import sys


def get_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(f"pdtrip.{name}")
    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(
            logging.Formatter(
                fmt="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
                datefmt="%Y-%m-%d %H:%M:%S",
            )
        )
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)
    return logger