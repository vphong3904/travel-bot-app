# TA-009 · KB Health Checker Dashboard
> **Phase:** P1 — Lõi vận hành  
> **Nhãn:** [FE+BE]  
> **Status:** ⬜ TODO  
> **Priority:** 🟠 HIGH  
> **Dependency:** TA-008 DONE (Knowledge Base CRUD)  
> **Estimated:** 3–4 giờ  
> **Thứ tự:** BE endpoint đọc disk → FE heatmap table → FE link sang Content

---

## Mục tiêu

Hiển thị trực quan **44/63 thành phố chỉ có README** — vấn đề thực tế đã gặp khi debug. Không có màn hình này admin không biết KB thiếu gì nếu không `ls` từng folder.

---

## PHẦN BACKEND

### B1 — Endpoint `GET /admin/kb-health`

```python
@router.get("/kb-health")
async def get_kb_health(
    current_user: User = Depends(require_role([
        UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.CONTENT_MANAGER
    ])),
):
    """
    Đọc thư mục knowledge-base/ trên disk.
    So sánh file hiện có vs file cần có cho mỗi thành phố.
    """
    import os
    from pathlib import Path
    from datetime import datetime

    # Đường dẫn tương đối từ thư mục chạy uvicorn (thường là backend/)
    # Điều chỉnh nếu cấu trúc folder khác
    KB_ROOT = Path("../knowledge-base")
    if not KB_ROOT.exists():
        KB_ROOT = Path("knowledge-base")
    if not KB_ROOT.exists():
        raise HTTPException(500, f"Không tìm thấy thư mục knowledge-base/")

    CONTENT_TYPES = [
        "destinations",
        "hotels",
        "restaurants",
        "foods",
        "transport",
        "tours",
        "events",
        "shopping",
        "itineraries",
        "experiences",
        "faq",
    ]

    FILE_NAMES = {ct: f"{ct}.json" if ct not in ("experiences", "faq") else f"{ct}.md"
                  for ct in CONTENT_TYPES}

    cities = []
    for city_dir in sorted(KB_ROOT.iterdir()):
        if not city_dir.is_dir():
            continue
        if city_dir.name.startswith("_") or city_dir.name.startswith("."):
            continue  # bỏ qua _global/ và .git/

        city_slug = city_dir.name
        files = {}
        has_any_data = False

        for ct in CONTENT_TYPES:
            fname = FILE_NAMES[ct]
            fpath = city_dir / fname
            if fpath.exists():
                size = fpath.stat().st_size
                last_modified = datetime.fromtimestamp(fpath.stat().st_mtime)
                # File < 200 bytes = chỉ có header/README placeholder
                is_empty = size < 200
                files[ct] = {
                    "exists": True,
                    "has_data": not is_empty,
                    "size_bytes": size,
                    "last_modified": last_modified.isoformat(),
                }
                if not is_empty:
                    has_any_data = True
            else:
                files[ct] = {"exists": False, "has_data": False}

        filled_count = sum(1 for v in files.values() if v["has_data"])
        cities.append({
            "city_slug": city_slug,
            "filled_count": filled_count,
            "total_count": len(CONTENT_TYPES),
            "completeness_pct": round(filled_count / len(CONTENT_TYPES) * 100),
            "has_any_data": has_any_data,
            "files": files,
        })

    # Thống kê tổng
    total_cities = len(cities)
    complete_cities = sum(1 for c in cities if c["completeness_pct"] == 100)
    empty_cities = sum(1 for c in cities if not c["has_any_data"])

    return {
        "summary": {
            "total_cities": total_cities,
            "complete_cities": complete_cities,
            "empty_cities": empty_cities,
            "avg_completeness_pct": round(
                sum(c["completeness_pct"] for c in cities) / total_cities
            ) if total_cities else 0,
        },
        "content_types": CONTENT_TYPES,
        "cities": cities,
    }
```

---

## PHẦN FRONTEND

### F1 — API function

```typescript
// src/api/admin/knowledge.ts (thêm vào)
export const knowledgeApi = {
  // ... existing methods ...
  getKbHealth: () =>
    api.get<KbHealthResponse>("/admin/kb-health"),
};

export interface KbHealthFile {
  exists: boolean;
  has_data: boolean;
  size_bytes?: number;
  last_modified?: string;
}

export interface KbHealthCity {
  city_slug: string;
  filled_count: number;
  total_count: number;
  completeness_pct: number;
  has_any_data: boolean;
  files: Record<string, KbHealthFile>;
}

export interface KbHealthResponse {
  summary: {
    total_cities: number;
    complete_cities: number;
    empty_cities: number;
    avg_completeness_pct: number;
  };
  content_types: string[];
  cities: KbHealthCity[];
}
```

### F2 — KBHealthPage

```typescript
// src/pages/knowledge/KBHealthPage.tsx
export function KBHealthPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["kb-health"],
    queryFn: () => knowledgeApi.getKbHealth().then(r => r.data),
    refetchInterval: 30_000,  // refresh 30s để bắt thay đổi khi import data
  });

  const navigate = useNavigate();

  if (isLoading) return <div className="p-6"><Skeleton className="h-96 w-full" /></div>;
  if (!data) return null;

  return (
    <div className="p-6 space-y-6">
      <PageHeader
        title="KB Health Checker"
        subtitle="Trạng thái dữ liệu knowledge-base/ theo từng thành phố"
      />

      {/* Summary Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <SummaryCard
          label="Tổng thành phố"
          value={data.summary.total_cities}
          color="text-foreground"
        />
        <SummaryCard
          label="Đầy đủ dữ liệu"
          value={data.summary.complete_cities}
          color="text-green-600"
        />
        <SummaryCard
          label="Chưa có dữ liệu"
          value={data.summary.empty_cities}
          color="text-red-600"
        />
        <SummaryCard
          label="Độ phủ trung bình"
          value={`${data.summary.avg_completeness_pct}%`}
          color={data.summary.avg_completeness_pct > 70 ? "text-green-600" : "text-amber-600"}
        />
      </div>

      {/* Chú thích */}
      <div className="flex gap-4 text-sm">
        <span className="flex items-center gap-1.5">
          <span className="w-4 h-4 rounded bg-green-500 inline-block" />
          Có dữ liệu
        </span>
        <span className="flex items-center gap-1.5">
          <span className="w-4 h-4 rounded bg-red-400 inline-block" />
          Không có / rỗng
        </span>
        <span className="flex items-center gap-1.5">
          <span className="w-4 h-4 rounded bg-muted border inline-block" />
          Chỉ có file rỗng
        </span>
      </div>

      {/* Heatmap Table */}
      <div className="overflow-x-auto rounded-lg border">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b bg-muted/50">
              <th className="px-4 py-3 text-left font-medium sticky left-0 bg-muted/50 min-w-[180px]">
                Thành phố
              </th>
              {data.content_types.map(ct => (
                <th key={ct} className="px-2 py-3 text-center font-medium min-w-[90px]">
                  <span className="block text-xs">{CT_LABELS[ct] || ct}</span>
                </th>
              ))}
              <th className="px-4 py-3 text-center font-medium">%</th>
            </tr>
          </thead>
          <tbody>
            {data.cities.map(city => (
              <tr key={city.city_slug} className="border-b hover:bg-muted/30">
                <td className="px-4 py-2.5 font-medium sticky left-0 bg-white text-xs">
                  {city.city_slug}
                </td>
                {data.content_types.map(ct => {
                  const file = city.files[ct];
                  return (
                    <td key={ct} className="px-2 py-2.5 text-center">
                      <button
                        onClick={() => {
                          if (!file?.has_data) {
                            navigate(`/content/${ct}?city_slug=${city.city_slug}`);
                          }
                        }}
                        title={
                          file?.has_data
                            ? `Có dữ liệu (${file.size_bytes} bytes)`
                            : `Thiếu dữ liệu — click để tạo`
                        }
                        className={`w-7 h-7 rounded flex items-center justify-center mx-auto transition ${
                          file?.has_data
                            ? "bg-green-500 cursor-default"
                            : file?.exists
                            ? "bg-muted border border-dashed cursor-pointer hover:border-red-400"
                            : "bg-red-400 cursor-pointer hover:bg-red-500"
                        }`}
                      >
                        {file?.has_data ? (
                          <span className="text-white text-xs">✓</span>
                        ) : (
                          <span className="text-white text-xs">✕</span>
                        )}
                      </button>
                    </td>
                  );
                })}
                {/* % column */}
                <td className="px-4 py-2.5 text-center">
                  <span
                    className={`text-xs font-bold ${
                      city.completeness_pct === 100
                        ? "text-green-600"
                        : city.completeness_pct > 50
                        ? "text-amber-600"
                        : "text-red-600"
                    }`}
                  >
                    {city.completeness_pct}%
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Top 5 thiếu nhiều nhất */}
      <div>
        <h3 className="font-medium mb-3">5 thành phố thiếu dữ liệu nhiều nhất</h3>
        <div className="space-y-2">
          {[...data.cities]
            .sort((a, b) => a.completeness_pct - b.completeness_pct)
            .slice(0, 5)
            .map(city => (
              <div key={city.city_slug} className="flex items-center gap-3">
                <span className="text-sm w-48 truncate">{city.city_slug}</span>
                <div className="flex-1 bg-muted rounded-full h-2">
                  <div
                    className="bg-red-400 h-2 rounded-full"
                    style={{ width: `${city.completeness_pct}%` }}
                  />
                </div>
                <span className="text-sm text-red-600 w-10 text-right">
                  {city.completeness_pct}%
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  className="text-xs h-7"
                  onClick={() => navigate(`/content/destinations?city_slug=${city.city_slug}`)}
                >
                  Nhập liệu →
                </Button>
              </div>
            ))}
        </div>
      </div>
    </div>
  );
}

// Label hiển thị cho content type
const CT_LABELS: Record<string, string> = {
  destinations: "Địa điểm",
  hotels: "Khách sạn",
  restaurants: "Nhà hàng",
  foods: "Ẩm thực",
  transport: "Di chuyển",
  tours: "Tour",
  events: "Sự kiện",
  shopping: "Mua sắm",
  itineraries: "Lịch trình",
  experiences: "Trải nghiệm",
  faq: "FAQ",
};
```

### F3 — Thêm link KB Health vào Knowledge page

```typescript
// Trong KnowledgePage — thêm nút "KB Health" trên PageHeader
<PageHeader
  title="Knowledge Base"
  action={
    <div className="flex gap-2">
      <Button variant="outline" onClick={() => navigate("/knowledge/health")}>
        🏥 KB Health
      </Button>
      <Button onClick={() => { setSelectedEntry(null); setFormOpen(true); }}>
        + Thêm mới
      </Button>
    </div>
  }
/>
```

---

## Checklist DONE

**Backend:**
- [ ] Endpoint đọc đúng đường dẫn `knowledge-base/` (không hardcode path tuyệt đối)
- [ ] Phân biệt được: file không tồn tại vs file tồn tại nhưng <200 bytes (rỗng)
- [ ] Bỏ qua folder `_global/` và file không phải folder
- [ ] Summary stats tính đúng

**Frontend:**
- [ ] Heatmap table scroll ngang được khi màn hình hẹp
- [ ] Cột thành phố sticky left khi scroll ngang
- [ ] Ô xanh không clickable; ô đỏ click → navigate đúng Content page
- [ ] Top 5 progress bar hiển thị đúng %
- [ ] Auto-refresh mỗi 30s (cập nhật khi có dữ liệu mới import)
- [ ] Bảng hiển thị đúng 34 thành phố (theo đơn vị hành chính sau sáp nhập 1/7/2025)

---

## Ghi chú khi DONE

```
completed_at:
notes:
```
