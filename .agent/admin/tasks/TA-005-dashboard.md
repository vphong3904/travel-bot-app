# TA-005 · Dashboard — Stats + Biểu đồ tổng hợp
> **Phase:** P1 — Lõi vận hành  
> **Nhãn:** [FE+BE]  
> **Status:** ⬜ TODO  
> **Priority:** 🟠 HIGH  
> **Dependency:** TA-001 DONE (RBAC)  
> **Estimated:** 4–5 giờ  
> **Thứ tự:** BE `/stats/overview` → FE KPI cards → FE biểu đồ

---

## Mục tiêu

Tổng hợp 4 stats endpoint đã có (`/stats/questions`, `/stats/destinations`, `/stats/chatbot`, `/stats/users`) thành 1 trang Dashboard có biểu đồ Recharts. Thêm endpoint `/stats/overview` gộp tất cả trong 1 call.

---

## PHẦN BACKEND

### B1 — Đọc 4 endpoint stats hiện có

```bash
cat backend/app/api/routes/admin.py | grep -A 30 "stats"
```

Xác nhận response format của từng endpoint rồi mới viết `/stats/overview`.

### B2 — Endpoint `/stats/overview`

```python
@router.get("/stats/overview")
async def get_stats_overview(
    period: str = Query("month", regex="^(day|week|month|quarter|year)$"),
    from_date: datetime | None = Query(None, alias="from"),
    to_date: datetime | None = Query(None, alias="to"),
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN,
        UserRole.CONTENT_MANAGER, UserRole.MODERATOR,
    ])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    """
    Gộp tất cả stats cho Dashboard page.
    Chạy các query PARALLEL bằng asyncio.gather để giảm latency.
    """
    import asyncio

    (
        user_stats,
        chat_stats,
        top_questions,
        top_destinations,
        unanswered_count,
        flagged_count,
    ) = await asyncio.gather(
        _get_user_stats(db, period),
        _get_chat_stats(db, period),
        _get_top_questions(db, limit=10),
        _get_top_destinations(db, limit=10),
        mongo_db["chatbot_unanswered_questions"].count_documents({"is_resolved": False}),
        mongo_db["chatbot_flagged_responses"].count_documents({"is_reviewed": False}),
    )

    return {
        "period": period,
        # KPI cards
        "kpi": {
            "total_users": user_stats["total"],
            "new_users_this_period": user_stats["new_count"],
            "total_chat_sessions": chat_stats["total_sessions"],
            "total_messages": chat_stats["total_messages"],
            "answered_rate": chat_stats["answered_rate"],   # float 0-1
            "pending_unanswered": unanswered_count,
            "pending_flagged": flagged_count,
        },
        # Biểu đồ
        "users_over_time": user_stats["over_time"],        # [{date, count}]
        "messages_over_time": chat_stats["over_time"],     # [{date, count}]
        "top_questions": top_questions,                    # [{question, count}]
        "top_destinations": top_destinations,              # [{destination, count}]
        "intent_breakdown": chat_stats["intent_breakdown"],# [{intent, count}]
    }
```

**Helper `_get_user_stats`:**
```python
async def _get_user_stats(db: AsyncSession, period: str) -> dict:
    total = await db.scalar(select(func.count(User.id)).where(User.is_deleted == False))
    
    # Tính from_date theo period
    now = datetime.now(timezone.utc)
    period_map = {"day": 1, "week": 7, "month": 30, "quarter": 90, "year": 365}
    since = now - timedelta(days=period_map.get(period, 30))
    
    new_count = await db.scalar(
        select(func.count(User.id))
        .where(User.created_at >= since, User.is_deleted == False)
    )
    
    # Users mới theo ngày trong period
    rows = await db.execute(
        select(
            func.date_trunc("day", User.created_at).label("date"),
            func.count(User.id).label("count")
        )
        .where(User.created_at >= since)
        .group_by(text("1"))
        .order_by(text("1"))
    )
    over_time = [{"date": r.date.isoformat(), "count": r.count} for r in rows]
    
    return {"total": total, "new_count": new_count, "over_time": over_time}
```

### B3 — Endpoint `/stats/export` (Excel)

```python
GET /admin/stats/export?format=excel&report=overview&period=month
```

Tái sử dụng data từ `/stats/overview`, dùng `openpyxl` build workbook, trả `StreamingResponse`.

---

## PHẦN FRONTEND

### F1 — API function

```typescript
// src/api/admin/dashboard.ts
export const dashboardApi = {
  getOverview: (params: { period?: string; from?: string; to?: string }) =>
    api.get("/admin/stats/overview", { params }),

  exportExcel: (period: string) =>
    api.get("/admin/stats/export", {
      params: { format: "excel", report: "overview", period },
      responseType: "blob",
    }),
};
```

### F2 — KPI Cards (4 card)

```typescript
// src/pages/dashboard/DashboardPage.tsx

// Layout: 4 card hàng trên + 4 biểu đồ bên dưới
// Card 1: Total Users (icon Users)        — mũi tên so kỳ trước
// Card 2: Chat Sessions (icon MessageSquare)
// Card 3: Answered Rate (icon CheckCircle) — % format
// Card 4: Pending Issues (icon AlertTriangle) — unanswered + flagged

function KpiCard({ title, value, icon: Icon, trend, color }) {
  return (
    <Card>
      <CardContent className="p-6">
        <div className="flex justify-between">
          <div>
            <p className="text-sm text-muted-foreground">{title}</p>
            <p className="text-3xl font-bold mt-1">{value}</p>
            {trend && (
              <p className={`text-xs mt-1 ${trend > 0 ? "text-green-600" : "text-red-600"}`}>
                {trend > 0 ? "▲" : "▼"} {Math.abs(trend)}% so kỳ trước
              </p>
            )}
          </div>
          <div className={`rounded-full p-3 ${color}`}>
            <Icon className="h-5 w-5 text-white" />
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
```

### F3 — 4 Biểu đồ Recharts

```typescript
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer
} from "recharts";

// Chart 1: Users mới theo ngày (Line)
function UsersLineChart({ data }) {
  return (
    <Card>
      <CardHeader><CardTitle>Người dùng mới</CardTitle></CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={250}>
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
            <XAxis dataKey="date" tick={{ fontSize: 12 }} />
            <YAxis tick={{ fontSize: 12 }} />
            <Tooltip />
            <Line type="monotone" dataKey="count" stroke="#3b82f6" strokeWidth={2} dot={false} />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}

// Chart 2: Top destinations (Bar ngang)
function TopDestinationsChart({ data }) {
  return (
    <Card>
      <CardHeader><CardTitle>Địa điểm được hỏi nhiều nhất</CardTitle></CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={280}>
          <BarChart data={data} layout="vertical">
            <XAxis type="number" tick={{ fontSize: 11 }} />
            <YAxis type="category" dataKey="destination" width={120} tick={{ fontSize: 11 }} />
            <Tooltip />
            <Bar dataKey="count" fill="#10b981" radius={[0, 4, 4, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}

// Chart 3: Intent breakdown (Pie)
const INTENT_COLORS = {
  ask_destination: "#3b82f6",
  find_hotel: "#8b5cf6",
  find_food: "#f59e0b",
  get_itinerary: "#10b981",
  other: "#6b7280",
};

function IntentPieChart({ data }) {
  return (
    <Card>
      <CardHeader><CardTitle>Phân loại Intent</CardTitle></CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={250}>
          <PieChart>
            <Pie data={data} dataKey="count" nameKey="intent" cx="50%" cy="50%" outerRadius={90} label>
              {data.map((entry) => (
                <Cell key={entry.intent} fill={INTENT_COLORS[entry.intent] || "#6b7280"} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}

// Chart 4: Messages theo ngày (Bar)
function MessagesBarChart({ data }) { /* tương tự UsersLineChart nhưng dùng BarChart */ }
```

### F4 — Period Selector + Export

```typescript
// Period selector ở góc phải PageHeader
const PERIODS = [
  { label: "Hôm nay", value: "day" },
  { label: "7 ngày", value: "week" },
  { label: "30 ngày", value: "month" },
  { label: "Quý này", value: "quarter" },
  { label: "Năm nay", value: "year" },
];

// Export Excel
async function handleExportExcel() {
  const res = await dashboardApi.exportExcel(period);
  const url = URL.createObjectURL(res.data);
  const a = document.createElement("a");
  a.href = url;
  a.download = `dashboard-${period}-${new Date().toISOString().slice(0, 10)}.xlsx`;
  a.click();
  URL.revokeObjectURL(url);
}
```

### F5 — DashboardPage tổng hợp

```typescript
export function DashboardPage() {
  const [period, setPeriod] = useState("month");

  const { data, isLoading } = useQuery({
    queryKey: ["dashboard", period],
    queryFn: () => dashboardApi.getOverview({ period }).then(r => r.data),
    refetchInterval: 60_000,   // tự refresh mỗi 60s
  });

  if (isLoading) return <DashboardSkeleton />;  // 4 card + 4 chart skeleton

  return (
    <div className="p-6 space-y-6">
      <PageHeader
        title="Dashboard"
        action={
          <div className="flex gap-2">
            <PeriodSelector value={period} onChange={setPeriod} />
            <Button variant="outline" onClick={handleExportExcel}>
              ⬇ Export Excel
            </Button>
          </div>
        }
      />

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard title="Tổng người dùng" value={data.kpi.total_users} icon={Users} color="bg-blue-500" />
        <KpiCard title="Chat Sessions" value={data.kpi.total_chat_sessions} icon={MessageSquare} color="bg-violet-500" />
        <KpiCard
          title="Tỉ lệ trả lời"
          value={`${(data.kpi.answered_rate * 100).toFixed(1)}%`}
          icon={CheckCircle}
          color="bg-emerald-500"
        />
        <KpiCard
          title="Chờ xử lý"
          value={data.kpi.pending_unanswered + data.kpi.pending_flagged}
          icon={AlertTriangle}
          color="bg-amber-500"
        />
      </div>

      {/* Charts 2×2 grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <UsersLineChart data={data.users_over_time} />
        <TopDestinationsChart data={data.top_destinations} />
        <IntentPieChart data={data.intent_breakdown} />
        <MessagesBarChart data={data.messages_over_time} />
      </div>
    </div>
  );
}
```

---

## Checklist DONE

**Backend:**
- [ ] `/stats/overview` dùng `asyncio.gather` — không waterfall query
- [ ] Period filter hoạt động (day/week/month/quarter/year)
- [ ] Response có đủ 4 nhóm data: kpi, users_over_time, top_destinations, intent_breakdown
- [ ] `/stats/export?format=excel` trả về file `.xlsx` tải được

**Frontend:**
- [ ] 4 KPI cards render đúng giá trị
- [ ] 4 biểu đồ Recharts hiển thị, có tooltip
- [ ] Period selector thay đổi → tất cả chart cập nhật
- [ ] Loading skeleton trong khi fetch (không flash trống)
- [ ] Export Excel tải file về máy

---

## Ghi chú khi DONE

```
completed_at:
notes:
```
