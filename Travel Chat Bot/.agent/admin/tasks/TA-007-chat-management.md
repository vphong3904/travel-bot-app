# TA-007 · Chat Management — Sessions + Messages + Unanswered
> **Phase:** P1 — Lõi vận hành  
> **Nhãn:** [FE+BE]  
> **Status:** ⬜ TODO  
> **Priority:** 🟠 HIGH  
> **Dependency:** TA-001 DONE  
> **Estimated:** 5–6 giờ  
> **Thứ tự:** Migration → BE routes → FE layout 2 cột → FE chat bubble → FE unanswered tab

---

## Mục tiêu

Xây màn hình Chat Management 2 cột: trái list sessions, phải xem chi tiết hội thoại dạng bubble. Tích hợp xử lý unanswered questions với flow "promote to KB".

---

## PHẦN BACKEND

### B1 — Migration: Thêm cột vào ChatSession

```bash
cd backend
alembic revision --autogenerate -m "add_tags_is_flagged_to_chat_sessions"
```

```python
# backend/app/db/models/chat.py — thêm vào class ChatSession
from sqlalchemy import ARRAY, Text, Boolean

tags: Mapped[list[str]] = mapped_column(ARRAY(Text), default=list, server_default="{}")
is_flagged: Mapped[bool] = mapped_column(Boolean, default=False)
```

### B2 — Route: GET /admin/chat-sessions

```python
@router.get("/chat-sessions", response_model=ChatSessionListResponse)
async def list_chat_sessions(
    user_id: UUID | None = Query(None),
    is_flagged: bool | None = Query(None),
    tag: str | None = Query(None),
    search: str | None = Query(None, description="Tìm trong tiêu đề session"),
    from_date: datetime | None = Query(None, alias="from"),
    to_date: datetime | None = Query(None, alias="to"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.MODERATOR
    ])),
    db: AsyncSession = Depends(get_db),
):
    query = select(ChatSession).where(ChatSession.is_deleted == False)
    
    if user_id:
        query = query.where(ChatSession.user_id == user_id)
    if is_flagged is not None:
        query = query.where(ChatSession.is_flagged == is_flagged)
    if tag:
        query = query.where(ChatSession.tags.contains([tag]))
    if search:
        query = query.where(ChatSession.title.ilike(f"%{search}%"))
    if from_date:
        query = query.where(ChatSession.created_at >= from_date)
    if to_date:
        query = query.where(ChatSession.created_at <= to_date)
    
    total = await db.scalar(select(func.count()).select_from(query.subquery()))
    query = query.order_by(ChatSession.updated_at.desc())
    query = query.offset((page-1)*page_size).limit(page_size)
    result = await db.execute(query)
    
    return ChatSessionListResponse(
        items=result.scalars().all(),
        total=total, page=page, page_size=page_size
    )
```

### B3 — Route: GET /admin/chat-sessions/{id}/messages

```python
@router.get("/chat-sessions/{session_id}/messages")
async def get_session_messages(
    session_id: UUID,
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.MODERATOR
    ])),
    db: AsyncSession = Depends(get_db),
):
    session = await db.get(ChatSession, session_id)
    if not session:
        raise HTTPException(404, "Session không tồn tại")
    
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
    )
    messages = result.scalars().all()
    
    return {
        "session": session,
        "messages": messages,
    }
```

### B4 — Route: PATCH /admin/chat-sessions/{id}

```python
@router.patch("/chat-sessions/{session_id}")
async def update_chat_session(
    session_id: UUID,
    body: ChatSessionUpdate,  # { tags?: str[], is_flagged?: bool }
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.MODERATOR
    ])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    session = await db.get(ChatSession, session_id)
    if not session:
        raise HTTPException(404)
    
    before = {"tags": session.tags, "is_flagged": session.is_flagged}
    
    if body.tags is not None:
        session.tags = body.tags
    if body.is_flagged is not None:
        session.is_flagged = body.is_flagged
    
    await db.commit()
    
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="update",
        resource_type="chat_session",
        resource_id=str(session_id),
        before_value=before,
        after_value={"tags": session.tags, "is_flagged": session.is_flagged},
    )
    return session
```

### B5 — Route: POST /admin/unanswered-questions/{id}/promote-to-kb

```python
@router.post("/unanswered-questions/{question_id}/promote-to-kb")
async def promote_to_knowledge_base(
    question_id: str,
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.CONTENT_MANAGER
    ])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    """
    Tạo KnowledgeEntry draft từ câu hỏi chưa trả lời.
    FE sẽ mở form Knowledge Base pre-filled với content từ câu hỏi này.
    """
    # Lấy câu hỏi từ MongoDB
    question = await mongo_db["chatbot_unanswered_questions"].find_one(
        {"id": question_id}
    )
    if not question:
        raise HTTPException(404, "Câu hỏi không tồn tại")
    
    # Tạo KnowledgeEntry draft
    entry = KnowledgeEntry(
        title=f"[DRAFT] {question['question'][:200]}",
        content=f"Câu hỏi: {question['question']}\n\nTrả lời: [Cần bổ sung]",
        category="faq",
        tags=["draft", "from-unanswered"],
        source="unanswered-questions",
        is_active=False,   # inactive cho đến khi review xong
    )
    db.add(entry)
    await db.flush()
    
    # Tạo embedding job (pending — chỉ embed sau khi is_active=True)
    # Thực ra với is_active=False nên chưa cần embed ngay
    # → chỉ tạo job khi admin publish entry này
    
    # Đánh dấu câu hỏi đã được xử lý
    await mongo_db["chatbot_unanswered_questions"].update_one(
        {"id": question_id},
        {"$set": {"is_promoted": True, "kb_entry_id": str(entry.id)}}
    )
    
    await db.commit()
    
    return {
        "kb_entry_id": str(entry.id),
        "message": "Đã tạo Knowledge Entry draft. Vào KB Management để hoàn thiện nội dung.",
    }
```

---

## PHẦN FRONTEND

### F1 — Layout 2 cột

```typescript
export function ChatPage() {
  const [selectedSessionId, setSelectedSessionId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<"sessions" | "unanswered" | "flagged">("sessions");

  return (
    <div className="flex h-[calc(100vh-64px)]">
      {/* Cột trái — 380px cố định */}
      <div className="w-[380px] border-r flex flex-col">
        {/* Tabs */}
        <div className="border-b p-3">
          <div className="flex gap-1 rounded-lg bg-muted p-1">
            {[
              { key: "sessions", label: "Hội thoại" },
              { key: "unanswered", label: "Chưa trả lời" },
              { key: "flagged", label: "Đánh dấu" },
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key as any)}
                className={`flex-1 rounded px-2 py-1.5 text-xs font-medium transition ${
                  activeTab === tab.key ? "bg-white shadow text-foreground" : "text-muted-foreground"
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* Content theo tab */}
        <div className="flex-1 overflow-y-auto">
          {activeTab === "sessions" && (
            <SessionList
              onSelect={setSelectedSessionId}
              selectedId={selectedSessionId}
            />
          )}
          {activeTab === "unanswered" && (
            <UnansweredList onSelect={setSelectedSessionId} />
          )}
          {activeTab === "flagged" && (
            <FlaggedList onSelect={setSelectedSessionId} />
          )}
        </div>
      </div>

      {/* Cột phải — flex-1 */}
      <div className="flex-1 overflow-hidden">
        {selectedSessionId ? (
          <ChatView sessionId={selectedSessionId} />
        ) : (
          <div className="flex h-full items-center justify-center text-muted-foreground text-sm">
            Chọn một hội thoại để xem chi tiết
          </div>
        )}
      </div>
    </div>
  );
}
```

### F2 — SessionList

```typescript
function SessionList({ onSelect, selectedId }) {
  const [search, setSearch] = useState("");
  const [filters, setFilters] = useState({ is_flagged: undefined, page: 1 });

  const { data } = useQuery({
    queryKey: ["chat-sessions", search, filters],
    queryFn: () => chatApi.listSessions({ search, ...filters }).then(r => r.data),
  });

  return (
    <>
      <div className="p-3 border-b">
        <Input
          placeholder="Tìm hội thoại..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="h-8 text-sm"
        />
      </div>

      {data?.items.map(session => (
        <button
          key={session.id}
          onClick={() => onSelect(session.id)}
          className={`w-full text-left p-3 border-b hover:bg-muted/50 transition ${
            selectedId === session.id ? "bg-muted" : ""
          }`}
        >
          <div className="flex items-start justify-between gap-2">
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate">
                {session.is_flagged && <span className="text-red-500 mr-1">🚩</span>}
                {session.title || "Hội thoại không tên"}
              </p>
              <p className="text-xs text-muted-foreground mt-0.5">
                {session.total_messages} tin · {formatRelativeTime(session.updated_at)}
              </p>
              {session.tags?.length > 0 && (
                <div className="flex gap-1 mt-1 flex-wrap">
                  {session.tags.map(tag => (
                    <span key={tag} className="px-1.5 py-0.5 bg-blue-100 text-blue-700 rounded text-xs">
                      {tag}
                    </span>
                  ))}
                </div>
              )}
            </div>
          </div>
        </button>
      ))}
    </>
  );
}
```

### F3 — ChatView (bubble view)

```typescript
function ChatView({ sessionId }) {
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ["chat-session-messages", sessionId],
    queryFn: () => chatApi.getSessionMessages(sessionId).then(r => r.data),
  });

  const updateSession = useMutation({
    mutationFn: (updates: { tags?: string[]; is_flagged?: boolean }) =>
      chatApi.updateSession(sessionId, updates),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["chat-sessions"] }),
  });

  if (isLoading) return <div className="p-4"><Skeleton className="h-full" /></div>;
  if (!data) return null;

  const { session, messages } = data;

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="border-b p-4 flex items-center justify-between">
        <div>
          <h3 className="font-medium">{session.title || "Hội thoại không tên"}</h3>
          <p className="text-xs text-muted-foreground">
            {session.total_messages} tin · {formatDate(session.created_at)}
          </p>
        </div>
        <div className="flex gap-2">
          <TagEditor
            tags={session.tags || []}
            onChange={tags => updateSession.mutate({ tags })}
          />
          <Button
            variant={session.is_flagged ? "destructive" : "outline"}
            size="sm"
            onClick={() => updateSession.mutate({ is_flagged: !session.is_flagged })}
          >
            🚩 {session.is_flagged ? "Bỏ đánh dấu" : "Đánh dấu"}
          </Button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map(msg => (
          <ChatBubble key={msg.id} message={msg} />
        ))}
      </div>
    </div>
  );
}
```

### F4 — ChatBubble với RAG details

```typescript
function ChatBubble({ message }) {
  const isUser = message.role === "user";

  return (
    <div className={`flex ${isUser ? "justify-end" : "justify-start"}`}>
      <div className={`max-w-[75%] ${isUser ? "order-2" : "order-1"}`}>
        {/* Bubble */}
        <div
          className={`rounded-2xl px-4 py-2.5 text-sm ${
            isUser
              ? "bg-blue-600 text-white rounded-br-sm"
              : "bg-muted rounded-bl-sm"
          }`}
        >
          {message.content}
        </div>

        {/* RAG details (chỉ hiện cho assistant) */}
        {!isUser && (
          <div className="mt-1 space-y-1">
            {/* Intent + confidence badges */}
            <div className="flex gap-1.5 flex-wrap">
              {message.intent && (
                <span className="px-2 py-0.5 bg-violet-100 text-violet-700 rounded text-xs">
                  {message.intent}
                </span>
              )}
              {message.confidence_score != null && (
                <span
                  className={`px-2 py-0.5 rounded text-xs ${
                    message.confidence_score > 0.7
                      ? "bg-green-100 text-green-700"
                      : message.confidence_score > 0.5
                      ? "bg-yellow-100 text-yellow-700"
                      : "bg-red-100 text-red-700"
                  }`}
                >
                  conf: {(message.confidence_score * 100).toFixed(0)}%
                </span>
              )}
              {message.cache_hit && (
                <span className="px-2 py-0.5 bg-teal-100 text-teal-700 rounded text-xs">
                  cache: {message.cache_hit}
                </span>
              )}
            </div>

            {/* Sources accordion */}
            {message.sources && message.sources.length > 0 && (
              <Collapsible>
                <CollapsibleTrigger className="text-xs text-muted-foreground hover:text-foreground">
                  {message.sources.length} nguồn ▾
                </CollapsibleTrigger>
                <CollapsibleContent>
                  <div className="mt-1 space-y-1 pl-2 border-l-2 border-muted">
                    {message.sources.map((src, i) => (
                      <div key={i} className="text-xs text-muted-foreground">
                        <span className="font-medium">{src.city_slug || src.category}</span>
                        {src.score && ` · score: ${src.score.toFixed(2)}`}
                      </div>
                    ))}
                  </div>
                </CollapsibleContent>
              </Collapsible>
            )}

            {/* Timestamp */}
            <p className="text-xs text-muted-foreground">
              {formatTime(message.created_at)}
              {message.latency_ms && ` · ${message.latency_ms}ms`}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
```

### F5 — UnansweredList với "Thêm vào KB"

```typescript
function UnansweredList({ onSelect }) {
  const queryClient = useQueryClient();

  const { data } = useQuery({
    queryKey: ["unanswered-questions"],
    queryFn: () => chatApi.listUnanswered({ is_resolved: false }).then(r => r.data),
  });

  const promoteToKb = useMutation({
    mutationFn: (questionId: string) => chatApi.promoteToKb(questionId),
    onSuccess: (res) => {
      toast.success("Đã tạo Knowledge Entry draft!");
      queryClient.invalidateQueries({ queryKey: ["unanswered-questions"] });
      // Navigate tới KB form với entry ID
    },
    onError: () => toast.error("Có lỗi xảy ra"),
  });

  return (
    <div>
      {data?.items.map(q => (
        <div key={q.id} className="p-3 border-b">
          <p className="text-sm">{q.question}</p>
          <p className="text-xs text-muted-foreground mt-0.5">
            {formatRelativeTime(q.created_at)}
          </p>
          <div className="mt-2 flex gap-2">
            <Button
              size="sm"
              variant="outline"
              className="text-xs h-7"
              onClick={() => promoteToKb.mutate(q.id)}
              disabled={q.is_promoted || promoteToKb.isPending}
            >
              {q.is_promoted ? "✓ Đã thêm vào KB" : "+ Thêm vào KB"}
            </Button>
          </div>
        </div>
      ))}
    </div>
  );
}
```

---

## Checklist DONE

**Backend:**
- [ ] Migration: `tags TEXT[]` và `is_flagged BOOLEAN` trên `chat_sessions`
- [ ] `GET /admin/chat-sessions` filter: user_id, is_flagged, tag, search, date range
- [ ] `GET /admin/chat-sessions/{id}/messages` trả đủ messages theo thứ tự
- [ ] `PATCH /admin/chat-sessions/{id}` cập nhật tags và is_flagged
- [ ] `POST /admin/unanswered-questions/{id}/promote-to-kb` tạo entry draft
- [ ] Audit log cho flag session và promote-to-kb

**Frontend:**
- [ ] Layout 2 cột: list trái, chat view phải
- [ ] 3 tabs: Hội thoại / Chưa trả lời / Đánh dấu
- [ ] Bubble view: user phải màu xanh, bot trái màu xám
- [ ] RAG badges: intent, confidence (màu theo score), cache hit
- [ ] Sources accordion có thể expand/collapse
- [ ] Nút 🚩 đánh dấu/bỏ đánh dấu session
- [ ] Tag editor trên session header
- [ ] "Thêm vào KB" disable sau khi đã promote

---

## Ghi chú khi DONE

```
completed_at:
notes:
```
