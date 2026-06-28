# TA-006 · User Management — List + Detail + Role
> **Phase:** P1 — Lõi vận hành  
> **Nhãn:** [FE+BE]  
> **Status:** ⬜ TODO  
> **Priority:** 🟠 HIGH  
> **Dependency:** TA-001 DONE (RBAC)  
> **Estimated:** 4–5 giờ  
> **Thứ tự:** Mở rộng BE GET /admin/users → route detail → FE bảng → FE drawer

---

## Mục tiêu

`GET /admin/users` đã có — mở rộng filter/pagination + thêm route detail/chat-history. Xây FE bảng danh sách + drawer chi tiết user với 2 tab.

---

## PHẦN BACKEND

### B1 — Đọc route hiện có

```bash
cat backend/app/api/routes/admin.py | grep -A 40 "admin/users"
cat backend/app/db/schemas/admin.py | grep -A 20 "User"
```

### B2 — Mở rộng GET /admin/users

```python
@router.get("/users", response_model=UserListResponse)
async def list_users(
    search: str | None = Query(None, description="Tìm theo email hoặc tên"),
    role: str | None = Query(None),
    is_active: bool | None = Query(None),
    from_date: datetime | None = Query(None, alias="from"),
    to_date: datetime | None = Query(None, alias="to"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])),
    db: AsyncSession = Depends(get_db),
):
    query = select(User).where(User.is_deleted == False)
    
    if search:
        query = query.where(
            or_(User.email.ilike(f"%{search}%"), User.full_name.ilike(f"%{search}%"))
        )
    if role:
        query = query.where(User.role == role)
    if is_active is not None:
        query = query.where(User.is_active == is_active)
    if from_date:
        query = query.where(User.created_at >= from_date)
    if to_date:
        query = query.where(User.created_at <= to_date)
    
    total = await db.scalar(select(func.count()).select_from(query.subquery()))
    query = query.order_by(User.created_at.desc()).offset((page-1)*page_size).limit(page_size)
    result = await db.execute(query)
    
    return UserListResponse(
        items=result.scalars().all(),
        total=total, page=page, page_size=page_size
    )
```

### B3 — Route mới: GET /admin/users/{id}

```python
@router.get("/users/{user_id}", response_model=UserDetailResponse)
async def get_user_detail(
    user_id: UUID,
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if not user or user.is_deleted:
        raise HTTPException(404, "User không tồn tại")
    
    # Stats tổng quan
    total_sessions = await db.scalar(
        select(func.count(ChatSession.id)).where(
            ChatSession.user_id == user_id, ChatSession.is_deleted == False
        )
    )
    total_messages = await db.scalar(
        select(func.count(ChatMessage.id))
        .join(ChatSession, ChatMessage.session_id == ChatSession.id)
        .where(ChatSession.user_id == user_id, ChatMessage.role == "user")
    )
    
    # 5 session gần nhất
    recent_result = await db.execute(
        select(ChatSession)
        .where(ChatSession.user_id == user_id, ChatSession.is_deleted == False)
        .order_by(ChatSession.updated_at.desc())
        .limit(5)
    )
    recent_sessions = recent_result.scalars().all()
    
    return UserDetailResponse(
        **user.__dict__,
        total_chat_sessions=total_sessions or 0,
        total_messages=total_messages or 0,
        recent_sessions=recent_sessions,
    )
```

### B4 — Schema bổ sung

```python
# app/db/schemas/admin.py — thêm
class ChatSessionSummary(BaseModel):
    id: UUID
    title: str | None
    total_messages: int
    updated_at: datetime
    class Config: from_attributes = True

class UserDetailResponse(BaseModel):
    id: UUID
    email: str
    full_name: str | None
    role: str
    is_active: bool
    auth_provider: str
    created_at: datetime
    updated_at: datetime
    # Thêm mới
    total_chat_sessions: int
    total_messages: int
    recent_sessions: list[ChatSessionSummary]
    class Config: from_attributes = True

class UserListResponse(BaseModel):
    items: list[UserResponse]   # UserResponse đã có
    total: int
    page: int
    page_size: int
```

### B5 — PATCH /admin/users/{id} (mở rộng)

```python
@router.patch("/users/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: UUID,
    body: UserUpdate,   # { is_active: bool | None, full_name: str | None }
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    user = await db.get(User, user_id)
    if not user or user.is_deleted:
        raise HTTPException(404, "User không tồn tại")
    
    before = {"is_active": user.is_active, "full_name": user.full_name}
    
    update_data = body.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)
    
    await db.commit()
    await db.refresh(user)
    
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="update",
        resource_type="user",
        resource_id=str(user_id),
        before_value=before,
        after_value={"is_active": user.is_active, "full_name": user.full_name},
    )
    return user
```

---

## PHẦN FRONTEND

### F1 — API functions

```typescript
// src/api/admin/users.ts
export const usersApi = {
  list: (params: { search?: string; role?: string; is_active?: boolean; page?: number; page_size?: number }) =>
    api.get<UserListResponse>("/admin/users", { params }),

  getDetail: (id: string) =>
    api.get<UserDetailResponse>(`/admin/users/${id}`),

  update: (id: string, data: { is_active?: boolean; full_name?: string }) =>
    api.patch<UserResponse>(`/admin/users/${id}`, data),

  updateRole: (id: string, role: string) =>
    api.patch<UserResponse>(`/admin/users/${id}/role`, { role }),
};
```

### F2 — UsersPage (bảng + drawer)

```typescript
export function UsersPage() {
  const [filters, setFilters] = useState({ search: "", role: "", page: 1 });
  const [selectedUser, setSelectedUser] = useState<string | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["users", filters],
    queryFn: () => usersApi.list(filters).then(r => r.data),
  });

  return (
    <div className="p-6 space-y-4">
      <PageHeader title="Người dùng" subtitle={`${data?.total || 0} tài khoản`} />

      {/* Filter bar */}
      <div className="flex gap-3 flex-wrap">
        <Input
          placeholder="Tìm email, tên..."
          value={filters.search}
          onChange={e => setFilters(f => ({ ...f, search: e.target.value, page: 1 }))}
          className="max-w-xs"
        />
        <Select value={filters.role} onValueChange={v => setFilters(f => ({ ...f, role: v, page: 1 }))}>
          <SelectTrigger className="w-40">
            <SelectValue placeholder="Tất cả role" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="">Tất cả</SelectItem>
            <SelectItem value="super_admin">Super Admin</SelectItem>
            <SelectItem value="admin">Admin</SelectItem>
            <SelectItem value="content_manager">Content Manager</SelectItem>
            <SelectItem value="moderator">Moderator</SelectItem>
            <SelectItem value="user">User</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Bảng */}
      <DataTable
        loading={isLoading}
        data={data?.items || []}
        columns={[
          {
            header: "Người dùng",
            render: row => (
              <div className="flex items-center gap-3">
                <Avatar className="h-8 w-8">
                  <AvatarFallback>{row.full_name?.[0] || row.email[0]}</AvatarFallback>
                </Avatar>
                <div>
                  <p className="font-medium text-sm">{row.full_name || "—"}</p>
                  <p className="text-xs text-muted-foreground">{row.email}</p>
                </div>
              </div>
            ),
          },
          {
            header: "Role",
            render: row => <RoleBadge role={row.role} />,
          },
          {
            header: "Trạng thái",
            render: row => (
              <Badge variant={row.is_active ? "default" : "secondary"}>
                {row.is_active ? "Đang hoạt động" : "Đã khoá"}
              </Badge>
            ),
          },
          {
            header: "Ngày đăng ký",
            render: row => formatDate(row.created_at),
          },
          {
            header: "",
            render: row => (
              <Button variant="ghost" size="sm" onClick={() => setSelectedUser(row.id)}>
                Chi tiết →
              </Button>
            ),
          },
        ]}
        pagination={{
          page: filters.page,
          pageSize: 20,
          total: data?.total || 0,
          onPageChange: p => setFilters(f => ({ ...f, page: p })),
        }}
        onRowClick={row => setSelectedUser(row.id)}
      />

      {/* Drawer detail */}
      <UserDetailDrawer
        userId={selectedUser}
        onClose={() => setSelectedUser(null)}
      />
    </div>
  );
}
```

### F3 — RoleBadge Component

```typescript
// src/components/shared/RoleBadge.tsx
const ROLE_CONFIG = {
  super_admin:     { label: "Super Admin", className: "bg-purple-100 text-purple-800" },
  admin:           { label: "Admin",       className: "bg-red-100 text-red-800" },
  content_manager: { label: "Content Mgr", className: "bg-orange-100 text-orange-800" },
  moderator:       { label: "Moderator",   className: "bg-blue-100 text-blue-800" },
  user:            { label: "User",        className: "bg-gray-100 text-gray-700" },
};

export function RoleBadge({ role }: { role: string }) {
  const cfg = ROLE_CONFIG[role] || { label: role, className: "bg-gray-100 text-gray-700" };
  return <span className={`px-2 py-0.5 rounded text-xs font-medium ${cfg.className}`}>{cfg.label}</span>;
}
```

### F4 — UserDetailDrawer

```typescript
export function UserDetailDrawer({ userId, onClose }) {
  const { data: user, isLoading } = useQuery({
    queryKey: ["user-detail", userId],
    queryFn: () => usersApi.getDetail(userId!).then(r => r.data),
    enabled: !!userId,
  });

  const { user: currentUser } = useAuthStore();
  const queryClient = useQueryClient();

  const toggleActive = useMutation({
    mutationFn: () => usersApi.update(userId!, { is_active: !user?.is_active }),
    onSuccess: () => {
      toast.success(user?.is_active ? "Đã khoá tài khoản" : "Đã mở khoá tài khoản");
      queryClient.invalidateQueries({ queryKey: ["users"] });
      queryClient.invalidateQueries({ queryKey: ["user-detail", userId] });
    },
  });

  return (
    <Sheet open={!!userId} onOpenChange={() => onClose()}>
      <SheetContent className="w-[480px]">
        {isLoading ? (
          <div className="space-y-3 mt-4">
            <Skeleton className="h-16 w-full" />
            <Skeleton className="h-40 w-full" />
          </div>
        ) : user ? (
          <>
            <SheetHeader className="pb-4">
              <div className="flex items-center gap-3">
                <Avatar className="h-12 w-12">
                  <AvatarFallback className="text-lg">
                    {user.full_name?.[0] || user.email[0]}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <SheetTitle>{user.full_name || "Chưa có tên"}</SheetTitle>
                  <p className="text-sm text-muted-foreground">{user.email}</p>
                </div>
              </div>
            </SheetHeader>

            <Tabs defaultValue="info">
              <TabsList className="w-full">
                <TabsTrigger value="info" className="flex-1">Thông tin</TabsTrigger>
                <TabsTrigger value="chat" className="flex-1">Lịch sử chat</TabsTrigger>
              </TabsList>

              <TabsContent value="info" className="space-y-4 pt-4">
                <div className="grid grid-cols-2 gap-3 text-sm">
                  <div>
                    <p className="text-muted-foreground">Role</p>
                    <RoleBadge role={user.role} />
                  </div>
                  <div>
                    <p className="text-muted-foreground">Trạng thái</p>
                    <Badge variant={user.is_active ? "default" : "secondary"}>
                      {user.is_active ? "Hoạt động" : "Đã khoá"}
                    </Badge>
                  </div>
                  <div>
                    <p className="text-muted-foreground">Đăng nhập qua</p>
                    <p className="font-medium capitalize">{user.auth_provider}</p>
                  </div>
                  <div>
                    <p className="text-muted-foreground">Ngày đăng ký</p>
                    <p className="font-medium">{formatDate(user.created_at)}</p>
                  </div>
                  <div>
                    <p className="text-muted-foreground">Chat sessions</p>
                    <p className="font-medium">{user.total_chat_sessions}</p>
                  </div>
                  <div>
                    <p className="text-muted-foreground">Tổng tin nhắn</p>
                    <p className="font-medium">{user.total_messages}</p>
                  </div>
                </div>

                {/* Actions */}
                <Separator />
                <div className="flex gap-2">
                  <Button
                    variant={user.is_active ? "destructive" : "default"}
                    size="sm"
                    onClick={() => toggleActive.mutate()}
                    disabled={toggleActive.isPending}
                  >
                    {user.is_active ? "Khoá tài khoản" : "Mở khoá"}
                  </Button>

                  {/* Chỉ SUPER_ADMIN thấy nút đổi role */}
                  {currentUser?.role === "super_admin" && (
                    <ChangeRoleDialog userId={user.id} currentRole={user.role} />
                  )}
                </div>
              </TabsContent>

              <TabsContent value="chat" className="pt-4">
                <p className="text-xs text-muted-foreground mb-3">5 hội thoại gần nhất</p>
                <div className="space-y-2">
                  {user.recent_sessions.map(session => (
                    <div key={session.id} className="rounded-lg border p-3 text-sm">
                      <p className="font-medium truncate">{session.title || "Hội thoại không tên"}</p>
                      <p className="text-xs text-muted-foreground mt-1">
                        {session.total_messages} tin · {formatDate(session.updated_at)}
                      </p>
                    </div>
                  ))}
                </div>
              </TabsContent>
            </Tabs>
          </>
        ) : null}
      </SheetContent>
    </Sheet>
  );
}
```

---

## Checklist DONE

**Backend:**
- [ ] `GET /admin/users` có filter: search, role, is_active
- [ ] `GET /admin/users/{id}` trả về total_sessions, total_messages, recent_sessions (5 item)
- [ ] `PATCH /admin/users/{id}` có audit log
- [ ] `PATCH /admin/users/{id}/role` chỉ SUPER_ADMIN (đã làm TA-001)

**Frontend:**
- [ ] Bảng danh sách với avatar, role badge, trạng thái
- [ ] Filter search + role + status hoạt động
- [ ] Click row → Drawer mở với 2 tab
- [ ] Khoá/mở khoá: confirm dialog + toast
- [ ] SUPER_ADMIN thấy "Đổi role" → modal chọn role mới
- [ ] RoleBadge màu đúng theo từng role

---

## Ghi chú khi DONE

```
completed_at:
notes:
```
