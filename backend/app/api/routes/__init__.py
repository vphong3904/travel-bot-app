from fastapi import APIRouter
from . import auth, chat_sessions, chat_messages, travel, trips, search, admin

api_router = APIRouter(prefix="/api")

# Auth: /auth/*
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])

# Chat sessions: /chat/sessions/*
api_router.include_router(chat_sessions.router, prefix="/chat/sessions", tags=["chat"])

# Chat messages: paths defined inside file already include /chat/sessions/{id}/messages
# so mount at root with no prefix
api_router.include_router(chat_messages.router, tags=["chat"])

# Travel: /travel/*
api_router.include_router(travel.router, prefix="/travel", tags=["travel"])

# Trips: /trips/*
api_router.include_router(trips.router, prefix="/trips", tags=["trips"])

# Search: /search/*
api_router.include_router(search.router, prefix="/search", tags=["search"])

# Admin: /admin/*
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
