from fastapi import APIRouter
from . import auth, chat_sessions, chat_messages, chat_guest, travel, trips, search, admin, reviews, favorites, content_public

api_router = APIRouter(prefix="/api")

# Auth: /auth/*
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])

# Chat sessions: /chat/sessions/*
api_router.include_router(chat_sessions.router, prefix="/chat/sessions", tags=["chat"])

# Chat messages: paths defined inside file already include /chat/sessions/{id}/messages
# so mount at root with no prefix
api_router.include_router(chat_messages.router, tags=["chat"])

# Chat guest: /chat/guest/stream  (no auth required)
api_router.include_router(chat_guest.router, tags=["chat-guest"])

# Travel: /travel/*
api_router.include_router(travel.router, prefix="/travel", tags=["travel"])

# Reviews: /travel/destinations/:id/reviews
api_router.include_router(reviews.router, prefix="/travel", tags=["reviews"])

# Favorites: /travel/favorites/*
api_router.include_router(favorites.router, prefix="/travel", tags=["favorites"])

# Trips: /trips/*
api_router.include_router(trips.router, prefix="/trips", tags=["trips"])

# Search: /search/*
api_router.include_router(search.router, prefix="/search", tags=["search"])

# Admin: /admin/*
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])

# Public content (mobile đọc content published): /content/*
api_router.include_router(content_public.router, prefix="/content", tags=["content"])