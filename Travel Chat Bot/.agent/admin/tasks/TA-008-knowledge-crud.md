# TA-008 · Knowledge Base — CRUD + Embedding Status Realtime
> **Phase:** P1 — Lõi vận hành  
> **Nhãn:** [FE+BE]  
> **Status:** ⬜ TODO  
> **Priority:** 🔴 CRITICAL — Được hỏi/test khi bảo vệ đồ án  
> **Dependency:** TA-001 DONE, TA-002 DONE, TA-003 DONE, TA-004 DONE  
> **Estimated:** 6–8 giờ  
> **Thứ tự:** BE route confirm → FE list → FE form → FE embedding status

---

## Mục tiêu

Xây dựng màn hình quản lý Knowledge Entries (bảng `knowledge_entries` Postgres). Backend đã có CRUD cơ bản tại `/admin/knowledge` — task này: **(1)** mở rộng schema/response, **(2)** đảm bảo luồng embedding 2 bước đúng như AR-08, **(3)** xây FE hoàn chỉnh với realtime embedding status.

---

## PHẦN BACKEND

### B1 — Đọc code hiện có trước khi sửa

```bash
# Đọc kỹ trước khi làm
cat backend/app/api/routes/admin.py | grep -A 50 "knowledge"
cat backend/app/db/schemas/admin.py
cat backend/app/db/models/admin.py
```

Xác nhận các endpoint đã có:
- `GET /admin/knowledge` — list
- `POST /admin/knowledge` — create
- `PATCH /admin/knowledge/{id}` — update
- `DELETE /admin/knowledge/{id}` — delete
- `POST /admin/knowledge/{id}/embed-now` — trigger embed
- `GET /admin/embedding-jobs` — list jobs

### B2 — Mở rộng Schema Response

**File:** `backend/app/db/schemas/admin.py`

```python
class KnowledgeEntryResponse(BaseModel):
    id: UUID
    title: str
    content: str
    category: str | None
    tags: list[str]
    source: str | None
    is_active: bool
    qdrant_id: UUID | None
    created_at: datetime
    updated_at: datetime
    # Thêm mới — embedding status
    embedding_status: str | None = None  # "pending" | "done" | "error" | None
    embedding_job_id: UUID | None = None
    last_embedded_at: datetime | None = None

    class Config:
        from_attributes = True

class KnowledgeEntryListResponse(BaseModel):
    items: list[KnowledgeEntryResponse]
    total: int
    page: int
    page_size: int

class KnowledgeEntryCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=500)
    content: str = Field(..., min_length=10)
    category: str | None = None
    tags: list[str] = []
    source: str | None = None
    is_active: bool = True

class KnowledgeEntryUpdate(BaseModel):
    title: str | None = Field(None, min_length=3, max_length=500)
    content: str | None = Field(None, min_length=10)
    category: str | None = None
    tags: list[str] | None = None
    source: str | None = None
    is_active: bool | None = None
```

### B3 — Mở rộng GET /admin/knowledge (thêm filter + embedding status)

```python
@router.get("/knowledge", response_model=KnowledgeEntryListResponse)
async def list_knowledge_entries(
    search: str | None = Query(None),
    category: str | None = Query(None),
    is_active: bool | None = Query(None),
    embedding_status: str | None = Query(None),  # "pending"|"done"|"error"|"not_embedded"
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.CONTENT_MANAGER
    ])),
    db: AsyncSession = Depends(get_db),
):
    """List knowledge entries với filter và pagination."""
    query = select(KnowledgeEntry)
    
    if search:
        query = query.where(
            or_(
                KnowledgeEntry.title.ilike(f"%{search}%"),
                KnowledgeEntry.content.ilike(f"%{search}%"),
            )
        )
    if category:
        query = query.where(KnowledgeEntry.category == category)
    if is_active is not None:
        query = query.where(KnowledgeEntry.is_active == is_active)
    
    # Count total
    total_result = await db.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    
    # Paginate + join embedding job status
    query = query.order_by(KnowledgeEntry.updated_at.desc())
    query = query.offset((page - 1) * page_size).limit(page_size)
    
    result = await db.execute(query)
    entries = result.scalars().all()
    
    # Enrich với embedding status từ embedding_jobs
    items = []
    for entry in entries:
        # Lấy job mới nhất cho entry này
        job_result = await db.execute(
            select(EmbeddingJob)
            .where(EmbeddingJob.entity_id == entry.id)
            .order_by(EmbeddingJob.created_at.desc())
            .limit(1)
        )
        latest_job = job_result.scalar_one_or_none()
        
        item = KnowledgeEntryResponse.from_orm(entry)
        if latest_job:
            item.embedding_status = latest_job.status
            item.embedding_job_id = latest_job.id
        elif entry.qdrant_id:
            item.embedding_status = "done"
        else:
            item.embedding_status = "not_embedded"
        
        items.append(item)
    
    # Filter by embedding_status nếu có (sau enrich)
    if embedding_status:
        items = [i for i in items if i.embedding_status == embedding_status]
    
    return KnowledgeEntryListResponse(items=items, total=total, page=page, page_size=page_size)
```

### B4 — Chuẩn hoá POST + PATCH để đảm bảo luồng AR-08

```python
@router.post("/knowledge", response_model=KnowledgeEntryResponse, status_code=201)
async def create_knowledge_entry(
    body: KnowledgeEntryCreate,
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.CONTENT_MANAGER
    ])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    entry = KnowledgeEntry(**body.dict())
    db.add(entry)
    await db.flush()  # flush để có entry.id trước khi tạo job
    
    # Tạo embedding job NGAY sau khi tạo entry
    job = EmbeddingJob(
        entity_id=entry.id,
        entity_type="knowledge_entry",
        status="pending",
    )
    db.add(job)
    await db.commit()
    await db.refresh(entry)
    await db.refresh(job)
    
    # Audit log
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="create",
        resource_type="knowledge_entry",
        resource_id=str(entry.id),
        after_value=body.dict(),
    )
    
    response = KnowledgeEntryResponse.from_orm(entry)
    response.embedding_status = "pending"
    response.embedding_job_id = job.id
    return response


@router.patch("/knowledge/{entry_id}", response_model=KnowledgeEntryResponse)
async def update_knowledge_entry(
    entry_id: UUID,
    body: KnowledgeEntryUpdate,
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.CONTENT_MANAGER
    ])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    entry = await db.get(KnowledgeEntry, entry_id)
    if not entry:
        raise HTTPException(404, "Không tìm thấy entry")
    
    before_value = {c.name: getattr(entry, c.name) for c in entry.__table__.columns}
    
    update_data = body.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(entry, field, value)
    
    # Nếu content thay đổi → tạo embedding job mới
    job = None
    if "content" in update_data or "title" in update_data:
        job = EmbeddingJob(
            entity_id=entry.id,
            entity_type="knowledge_entry",
            status="pending",
        )
        db.add(job)
    
    await db.commit()
    await db.refresh(entry)
    
    # Audit log
    after_value = {c.name: getattr(entry, c.name) for c in entry.__table__.columns}
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="update",
        resource_type="knowledge_entry",
        resource_id=str(entry_id),
        before_value=before_value,
        after_value=after_value,
    )
    
    response = KnowledgeEntryResponse.from_orm(entry)
    if job:
        await db.refresh(job)
        response.embedding_status = "pending"
        response.embedding_job_id = job.id
    return response


@router.delete("/knowledge/{entry_id}", status_code=204)
async def delete_knowledge_entry(
    entry_id: UUID,
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    entry = await db.get(KnowledgeEntry, entry_id)
    if not entry:
        raise HTTPException(404, "Không tìm thấy entry")
    
    before_value = {c.name: getattr(entry, c.name) for c in entry.__table__.columns}
    
    # Soft delete: set is_active = False thay vì xóa thật
    entry.is_active = False
    await db.commit()
    
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="delete",
        resource_type="knowledge_entry",
        resource_id=str(entry_id),
        before_value=before_value,
    )


@router.get("/embedding-jobs/{job_id}")
async def get_embedding_job_status(
    job_id: UUID,
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.CONTENT_MANAGER
    ])),
    db: AsyncSession = Depends(get_db),
):
    """Polling endpoint — FE gọi mỗi 3 giây để kiểm tra embedding status."""
    job = await db.get(EmbeddingJob, job_id)
    if not job:
        raise HTTPException(404, "Job không tồn tại")
    return {
        "job_id": str(job.id),
        "status": job.status,
        "error": job.error,
        "updated_at": job.updated_at,
    }
```

---

## PHẦN FRONTEND

### F1 — API functions

**File:** `src/api/admin/knowledge.ts`

```typescript
import { api } from "@/lib/api";

export interface KnowledgeEntry {
  id: string;
  title: string;
  content: string;
  category: string | null;
  tags: string[];
  source: string | null;
  is_active: boolean;
  qdrant_id: string | null;
  embedding_status: "pending" | "done" | "error" | "not_embedded" | null;
  embedding_job_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface KnowledgeEntryForm {
  title: string;
  content: string;
  category?: string;
  tags?: string[];
  source?: string;
  is_active?: boolean;
}

export const knowledgeApi = {
  list: (params: {
    search?: string;
    category?: string;
    is_active?: boolean;
    embedding_status?: string;
    page?: number;
    page_size?: number;
  }) => api.get<{ items: KnowledgeEntry[]; total: number; page: number; page_size: number }>(
    "/admin/knowledge",
    { params }
  ),

  create: (data: KnowledgeEntryForm) =>
    api.post<KnowledgeEntry>("/admin/knowledge", data),

  update: (id: string, data: Partial<KnowledgeEntryForm>) =>
    api.patch<KnowledgeEntry>(`/admin/knowledge/${id}`, data),

  delete: (id: string) =>
    api.delete(`/admin/knowledge/${id}`),

  embedNow: (id: string) =>
    api.post(`/admin/knowledge/${id}/embed-now`),

  getJobStatus: (jobId: string) =>
    api.get<{ job_id: string; status: string; error: string | null; updated_at: string }>(
      `/admin/embedding-jobs/${jobId}`
    ),
};
```

### F2 — EmbeddingStatusBadge Component

```typescript
// src/components/shared/EmbeddingStatusBadge.tsx
import { useEffect, useState } from "react";
import { Badge } from "@/components/ui/badge";
import { Loader2, CheckCircle, XCircle, AlertCircle } from "lucide-react";
import { knowledgeApi } from "@/api/admin/knowledge";

interface Props {
  status: string | null;
  jobId: string | null;
  onStatusChange?: (newStatus: string) => void;
}

export function EmbeddingStatusBadge({ status, jobId, onStatusChange }: Props) {
  const [currentStatus, setCurrentStatus] = useState(status);

  // Polling khi status = "pending"
  useEffect(() => {
    if (currentStatus !== "pending" || !jobId) return;

    let attempts = 0;
    const MAX_ATTEMPTS = 20; // 20 × 3s = 60 giây tối đa

    const interval = setInterval(async () => {
      attempts++;
      if (attempts > MAX_ATTEMPTS) {
        clearInterval(interval);
        return;
      }
      try {
        const res = await knowledgeApi.getJobStatus(jobId);
        if (res.data.status !== "pending") {
          setCurrentStatus(res.data.status);
          onStatusChange?.(res.data.status);
          clearInterval(interval);
        }
      } catch {
        clearInterval(interval);
      }
    }, 3000);

    return () => clearInterval(interval);
  }, [currentStatus, jobId]);

  const config = {
    pending: { label: "Đang embed...", icon: Loader2, variant: "secondary", spin: true },
    done: { label: "Đã đồng bộ ✓", icon: CheckCircle, variant: "success", spin: false },
    error: { label: "Lỗi embed", icon: XCircle, variant: "destructive", spin: false },
    not_embedded: { label: "Chưa embed", icon: AlertCircle, variant: "outline", spin: false },
  }[currentStatus || "not_embedded"] || { label: "—", icon: AlertCircle, variant: "outline", spin: false };

  const Icon = config.icon;

  return (
    <Badge variant={config.variant as any} className="gap-1 text-xs">
      <Icon className={`h-3 w-3 ${config.spin ? "animate-spin" : ""}`} />
      {config.label}
    </Badge>
  );
}
```

### F3 — KnowledgePage chính

```typescript
// src/pages/knowledge/KnowledgePage.tsx
// Layout: PageHeader + FilterBar + DataTable + Sheet (form tạo/sửa)

export function KnowledgePage() {
  const [filters, setFilters] = useState({ search: "", category: "", page: 1 });
  const [selectedEntry, setSelectedEntry] = useState<KnowledgeEntry | null>(null);
  const [formOpen, setFormOpen] = useState(false);

  const { data, isLoading, refetch } = useQuery({
    queryKey: ["knowledge", filters],
    queryFn: () => knowledgeApi.list(filters).then(r => r.data),
  });

  const columns = [
    { header: "Tiêu đề", accessor: "title" },
    { header: "Category", accessor: "category" },
    { header: "Tags", render: (row) => row.tags.join(", ") },
    { header: "Trạng thái", render: (row) => (
      <EmbeddingStatusBadge
        status={row.embedding_status}
        jobId={row.embedding_job_id}
        onStatusChange={() => refetch()}
      />
    )},
    { header: "Cập nhật", render: (row) => formatDate(row.updated_at) },
    { header: "", render: (row) => (
      <div className="flex gap-2">
        <Button variant="ghost" size="sm" onClick={() => { setSelectedEntry(row); setFormOpen(true); }}>
          Sửa
        </Button>
        <DeleteKnowledgeButton id={row.id} onSuccess={refetch} />
      </div>
    )},
  ];

  return (
    <div className="p-6 space-y-4">
      <PageHeader
        title="Knowledge Base"
        subtitle={`${data?.total || 0} entries`}
        action={
          <Button onClick={() => { setSelectedEntry(null); setFormOpen(true); }}>
            + Thêm mới
          </Button>
        }
      />
      
      {/* Filter bar */}
      <div className="flex gap-3">
        <Input
          placeholder="Tìm kiếm tiêu đề, nội dung..."
          value={filters.search}
          onChange={(e) => setFilters(f => ({ ...f, search: e.target.value, page: 1 }))}
          className="max-w-sm"
        />
        <Select
          value={filters.category}
          onValueChange={(v) => setFilters(f => ({ ...f, category: v, page: 1 }))}
        >
          {/* Options category */}
        </Select>
      </div>

      <DataTable
        columns={columns}
        data={data?.items || []}
        loading={isLoading}
        pagination={{
          page: filters.page,
          pageSize: 20,
          total: data?.total || 0,
          onPageChange: (p) => setFilters(f => ({ ...f, page: p })),
        }}
      />

      {/* Form Sheet */}
      <KnowledgeFormSheet
        open={formOpen}
        entry={selectedEntry}
        onClose={() => setFormOpen(false)}
        onSuccess={() => { setFormOpen(false); refetch(); }}
      />
    </div>
  );
}
```

### F4 — KnowledgeFormSheet (Create/Edit)

```typescript
// src/pages/knowledge/KnowledgeFormSheet.tsx

const schema = z.object({
  title: z.string().min(3, "Tối thiểu 3 ký tự").max(500),
  content: z.string().min(10, "Tối thiểu 10 ký tự"),
  category: z.string().optional(),
  tags: z.array(z.string()).optional(),
  source: z.string().optional(),
  is_active: z.boolean().default(true),
});

export function KnowledgeFormSheet({ open, entry, onClose, onSuccess }) {
  const queryClient = useQueryClient();
  const isEdit = !!entry;
  
  const form = useForm({ resolver: zodResolver(schema), defaultValues: entry || {} });
  
  const mutation = useMutation({
    mutationFn: (data) => isEdit
      ? knowledgeApi.update(entry.id, data)
      : knowledgeApi.create(data),
    onSuccess: (res) => {
      const status = res.data.embedding_status;
      if (status === "pending") {
        toast.info("Đang tạo embedding... Badge sẽ tự cập nhật.");
      } else {
        toast.success(isEdit ? "Cập nhật thành công" : "Tạo thành công");
      }
      onSuccess();
    },
    onError: () => toast.error("Có lỗi xảy ra"),
  });

  return (
    <Sheet open={open} onOpenChange={onClose}>
      <SheetContent className="w-[600px] sm:max-w-[600px]">
        <SheetHeader>
          <SheetTitle>{isEdit ? "Chỉnh sửa Entry" : "Thêm Knowledge Entry"}</SheetTitle>
        </SheetHeader>
        
        <form onSubmit={form.handleSubmit(data => mutation.mutate(data))} className="space-y-4 mt-4">
          <FormField label="Tiêu đề *" error={form.formState.errors.title?.message}>
            <Input {...form.register("title")} />
          </FormField>
          
          <FormField label="Nội dung *" error={form.formState.errors.content?.message}>
            <Textarea {...form.register("content")} rows={8} />
          </FormField>
          
          <FormField label="Category">
            <Input {...form.register("category")} placeholder="faq, policy, ..." />
          </FormField>
          
          <FormField label="Tags (phân cách bằng dấu phẩy)">
            <TagInput value={form.watch("tags") || []} onChange={(tags) => form.setValue("tags", tags)} />
          </FormField>
          
          <FormField label="Nguồn">
            <Input {...form.register("source")} placeholder="vietnamtourism.gov.vn" />
          </FormField>
          
          <div className="flex items-center gap-2">
            <Switch {...form.register("is_active")} />
            <label>Kích hoạt</label>
          </div>
          
          {/* Embedding status nếu đang sửa */}
          {isEdit && (
            <div className="rounded-md bg-muted p-3 text-sm">
              <span className="text-muted-foreground">Embedding: </span>
              <EmbeddingStatusBadge
                status={entry.embedding_status}
                jobId={entry.embedding_job_id}
              />
              <p className="mt-1 text-xs text-muted-foreground">
                Khi bạn lưu thay đổi tiêu đề hoặc nội dung, hệ thống sẽ tự động tạo embedding mới.
              </p>
            </div>
          )}
          
          <div className="flex justify-end gap-2 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>Hủy</Button>
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending ? "Đang lưu..." : "Lưu"}
            </Button>
          </div>
        </form>
      </SheetContent>
    </Sheet>
  );
}
```

---

## Checklist DONE

**Backend:**
- [ ] `GET /admin/knowledge` trả về `embedding_status` cho mỗi entry
- [ ] `POST /admin/knowledge` tạo `EmbeddingJob` ngay lập tức (không async-fire-and-forget)
- [ ] `PATCH /admin/knowledge/{id}` tạo job mới khi content/title thay đổi
- [ ] `DELETE /admin/knowledge/{id}` là soft delete (is_active=False)
- [ ] `GET /admin/embedding-jobs/{job_id}` endpoint polling hoạt động
- [ ] Audit log cho create, update, delete
- [ ] CONTENT_MANAGER có quyền create/update, chỉ ADMIN+ có quyền delete

**Frontend:**
- [ ] DataTable hiển thị list với phân trang
- [ ] Filter search + category hoạt động
- [ ] Tạo mới qua Sheet form → submit → badge hiện "Đang embed..." → tự chuyển "Đã đồng bộ ✓"
- [ ] Sửa qua Sheet form → submit → badge tự cập nhật
- [ ] Xóa: confirm dialog trước khi xóa
- [ ] EmbeddingStatusBadge polling tự dừng sau 60s hoặc khi status thay đổi
- [ ] Toast thông báo thành công/lỗi

---

## Ghi chú khi DONE

```
completed_at:
notes:
```
