# TA-016 · Content Management — 9 loại còn lại
> **Phase:** P3  |  **Nhãn:** [FE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-015 DONE  |  **Estimated:** 3–4 giờ

## Mục tiêu
Backend đã xong (generic router từ TA-015). Chỉ tạo FE page với columns + schema phù hợp.

## Pattern
```typescript
// Mỗi page ~ 30 dòng
export function ToursPage() {
  return <ContentPage contentType="tours" columns={toursColumns} formSchema={toursSchema} formFields={toursFields} />;
}
```

## 9 loại + Columns chính

| Page | Columns bảng |
|---|---|
| ToursPage | Tên, Loại (solo/couple/family), Giá, Thời gian, Status |
| FoodsPage | Tên món, Loại (đặc sản/street food), Mô tả ngắn, Status |
| RestaurantsPage | Tên, Địa chỉ, Giờ mở, Loại ẩm thực, Status |
| ShoppingPage | Tên địa điểm, Loại hàng, Khu vực, Status |
| ItinerariesPage | Tiêu đề, Số ngày, Loại, Số địa điểm, Status |
| EventsPage | Tên sự kiện, Ngày, Địa điểm, Loại, Status |
| TransportPage | Phương tiện, Tuyến, Giá ước tính, Status |
| FaqPage | Câu hỏi (80 ký tự), Category, Status |
| ExperiencesPage | Tiêu đề, Mô tả ngắn, Status |

## Checklist DONE
- [ ] 9 pages đều render, CRUD hoạt động qua ContentPage template
- [ ] Sidebar routes trỏ đúng

```
completed_at:
```
