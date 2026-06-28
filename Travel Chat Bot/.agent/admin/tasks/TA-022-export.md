# TA-022 · Export Excel/PDF
> **Phase:** P4  |  **Nhãn:** [BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-005 DONE  |  **Estimated:** 2 giờ

## Backend

Thêm vào `requirements.txt`: `openpyxl>=3.1.0`

```python
GET /admin/stats/export?format=excel&report=overview|users|feedback&period=month
```

```python
from openpyxl import Workbook
from fastapi.responses import StreamingResponse
import io

@router.get("/stats/export")
async def export_stats(format: str = Query(..., regex="^(excel)$"),
                       report: str = Query("overview"),
                       period: str = Query("month"),
                       current_user = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])), ...):
    data = await _get_report_data(report, period, db, mongo_db)
    
    wb = Workbook()
    ws = wb.active
    ws.title = f"{report}_{period}"
    
    # Header row (bold)
    headers = list(data[0].keys()) if data else []
    for col, h in enumerate(headers, 1):
        cell = ws.cell(row=1, column=col, value=h)
        cell.font = Font(bold=True)
    
    # Data rows
    for row_idx, row in enumerate(data, 2):
        for col_idx, val in enumerate(row.values(), 1):
            ws.cell(row=row_idx, column=col_idx, value=str(val) if val else "")
    
    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)
    
    filename = f"pdtrip_{report}_{period}_{date.today()}.xlsx"
    return StreamingResponse(buf,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename={filename}"})
```

**FE:** Nút "⬇ Export Excel" trên Dashboard page → download blob.

## Checklist DONE
- [ ] File xlsx tải được, mở không lỗi
- [ ] Header row bold
- [ ] Filename có ngày

```
completed_at:
```
