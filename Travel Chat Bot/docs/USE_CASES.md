# Đặc tả Use Case — PDTrip AI

Sơ đồ use case trực quan xem trong `PDTrip_AI_Phan_Tich_Thiet_Ke.docx` (Mục 3). Tài liệu này bổ sung
đặc tả dạng bảng để dùng trong báo cáo đồ án và làm cơ sở phát triển Web Admin.

## Tác nhân (Actors)

| Tác nhân | Mô tả | Kế thừa |
|---|---|---|
| Khách vãng lai | Chưa đăng nhập, chat thử giới hạn lượt | — |
| Người dùng | Đã đăng nhập, dùng đầy đủ tính năng người dùng cuối | ← Khách vãng lai |
| Moderator | Giám sát hội thoại & phản hồi | nhân viên quản trị |
| Content Manager | Quản lý tri thức & nội dung du lịch | nhân viên quản trị |
| Admin | Vận hành toàn hệ thống (trừ cấu hình ghi & đổi vai trò super) | ← Moderator, Content Manager |
| Super Admin | Toàn quyền: phân quyền, cấu hình, audit | ← Admin |

## Nhóm Use Case người dùng cuối

| Mã | Use case | Tác nhân | Tóm tắt luồng chính |
|---|---|---|---|
| UC-01 | Chat thử (khách) | Khách | Kiểm tra hạn mức → chạy RAG → trả lời (không lưu lịch sử); hết lượt → mời đăng nhập |
| UC-02 | Đăng ký + OTP | Khách | Gửi OTP email → xác nhận OTP → tạo tài khoản đã xác thực |
| UC-03 | Đăng nhập / Google | Khách | Xác thực → cấp access JWT + refresh cookie |
| UC-04 | Quên / đổi mật khẩu | Khách/Người dùng | OTP đặt lại mật khẩu; đổi mật khẩu khi đã đăng nhập |
| UC-05 | Hỏi đáp RAG | Người dùng | Gửi câu hỏi → pipeline RAG (cache/hybrid/Gemini) → trả lời streaming SSE |
| UC-06 | Lịch sử hội thoại | Người dùng | Liệt kê/đọc lại phiên & tin nhắn, pin/đổi tên/xoá phiên |
| UC-07 | Đánh giá câu trả lời | Người dùng | Gửi feedback 👍/👎 cho từng tin nhắn |
| UC-08 | Khám phá điểm đến | Người dùng | Tìm kiếm/lọc, xem chi tiết, xem khách sạn/tour/vé/sự kiện… |
| UC-09 | Yêu thích | Người dùng | Thêm/bỏ điểm đến yêu thích |
| UC-10 | Đánh giá điểm đến | Người dùng | Viết review (rating 1–5 + nội dung) |
| UC-11 | Lập kế hoạch chuyến đi | Người dùng | Tạo trip plan → thêm hoạt động theo ngày → xem lịch trình |
| UC-12 | Quản lý hồ sơ | Người dùng | Cập nhật thông tin cá nhân, avatar |

## Nhóm Use Case quản trị

| Mã | Use case | Tác nhân được phép | Ghi chú |
|---|---|---|---|
| UC-A1 | Dashboard & thống kê | Admin, Content Mgr (đọc), Moderator (đọc) | Biểu đồ, số liệu tổng hợp |
| UC-A2 | Quản lý người dùng | Admin; đổi vai trò: Super Admin | Bật/tắt, đổi role |
| UC-A3 | Giám sát hội thoại | Admin, Moderator | Xem chat-log, câu hỏi chưa trả lời |
| UC-A4 | Quản lý Knowledge Base | Admin, Content Mgr | CRUD entry → embedding job → Qdrant («include» Audit) |
| UC-A5 | Quản lý nội dung du lịch | Admin, Content Mgr | Điểm đến, khách sạn, tour… |
| UC-A6 | Quản lý phản hồi | Admin, Moderator | Xử lý feedback, flagged responses |
| UC-A7 | Giám sát AI/RAG | Admin | Latency, cache hit, chất lượng trả lời |
| UC-A8 | Phân quyền (đổi vai trò) | Super Admin | Ghi audit role_change (before/after) |
| UC-A9 | Cấu hình hệ thống | Super Admin | Tham số vận hành |
| UC-A10 | Xem Audit Log | Super Admin (đọc Admin) | Truy vết hành động admin |

## Ràng buộc & quan hệ

- «include»: UC-05 (Hỏi đáp RAG đầy đủ) yêu cầu đăng nhập (UC-03); mọi UC quản trị có thay đổi dữ liệu «include» ghi Audit Log (UC-A10/A8).
- Ma trận phân quyền chi tiết: xem `.agent/admin/rules/ADMIN_AGENT_RULES.md` (AR-09).
