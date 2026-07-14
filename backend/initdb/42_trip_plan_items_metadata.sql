-- 42_trip_plan_items_metadata.sql
-- Bổ sung time_slot/type/ref_id/image_url vào trip_plan_items — trước đây
-- /trips/ai/confirm bỏ trống các trường này khi lưu, khiến ảnh + buổi trong
-- ngày (sáng/trưa/chiều/tối) + loại mục (khách sạn/quán ăn/điểm/free) MẤT
-- VĨNH VIỄN ngay khi user lưu chuyến đi. ref_id KHÔNG có FK vì có thể trỏ
-- hotels/restaurants/locations tuỳ giá trị `type`. An toàn với dữ liệu cũ:
-- chỉ thêm cột mới, đều nullable/có default, không đụng dữ liệu hiện có.

ALTER TABLE trip_plan_items
    ADD COLUMN IF NOT EXISTS time_slot VARCHAR(20),
    ADD COLUMN IF NOT EXISTS type      VARCHAR(20) DEFAULT 'free',
    ADD COLUMN IF NOT EXISTS ref_id    UUID,
    ADD COLUMN IF NOT EXISTS image_url TEXT;
