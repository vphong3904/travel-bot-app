# AI Travel Advisor - Backend (FastAPI)

FastAPI backend cho chatbot tư vấn du lịch với NLP, Intent Recognition và RAG.

## Chạy

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

API docs: http://localhost:8000/docs

## Tài khoản demo

- admin@travel.ai / admin123
- user@travel.ai / user123

## RAG (tùy chọn)

```bash
pip install -r requirements-rag.txt
```
