-- 43_trip_plans_estimated_cost.sql
-- /trips/ai/confirm nhận estimated_cost trong payload nhưng trước đây bỏ
-- trống khi tạo TripPlan → chuyến đi đã lưu mất luôn chi phí ước tính, màn
-- xem lại chi tiết không hiện được. An toàn: cột mới nullable, không đụng
-- dữ liệu cũ.

ALTER TABLE trip_plans
    ADD COLUMN IF NOT EXISTS estimated_cost INT CHECK (estimated_cost >= 0);
