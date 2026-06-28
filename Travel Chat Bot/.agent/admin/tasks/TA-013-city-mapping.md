# TA-013 · Province/City Slug Mapping Manager
> **Phase:** P2  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-001 DONE  |  **Estimated:** 3–4 giờ

## Mục tiêu
Giải quyết bug slug alias trỏ tới folder không tồn tại.

## Backend — 3 Endpoints

```python
GET /admin/city-mappings/validate
# Đọc city_slug_alias.json + os.listdir("knowledge-base/")
# Returns: [{ old_province, mapped_slug, folder_exists: bool, suggestion? }]
# suggestion = slug gần nhất theo edit-distance nếu folder_exists=False

PATCH /admin/city-mappings/{old_province}
# body: { new_slug: "slug-từ-danh-sách-folder-thật" }
# Đọc city_slug_alias.json → sửa mapping → ghi lại file
# Audit log bắt buộc

GET /admin/city-mappings/valid-slugs
# Returns: list[str] = os.listdir("knowledge-base/") filter chỉ thư mục
```

## Frontend

**Bảng 4 cột:** Tỉnh cũ | Slug hiện tại | Folder tồn tại? | Action

Dòng `folder_exists=False` → background đỏ nhạt + icon ❌.

Khi click [Sửa]:
- Dropdown `<Select>` chọn slug từ `/valid-slugs` (không cho nhập tay)
- Confirm dialog trước khi lưu
- Sau lưu: refetch `/validate` để cập nhật trạng thái

**Badge tổng quan:** "X/Y mapping có vấn đề" — màu đỏ nếu X > 0.

## Checklist DONE
- [ ] Validate auto khi vào trang (không cần bấm nút)
- [ ] Dropdown chỉ có slug thật từ disk
- [ ] Sửa mapping → cập nhật file JSON thật
- [ ] Audit log
- [ ] Sau khi sửa xong, bảng refetch và tô xanh dòng đã fix

```
completed_at:
```
