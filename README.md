# Bộ Công Cụ Quản Lý Tường Lửa Tự Động (UFW Makefile)

Tệp `Makefile` này giúp tự động hóa việc cấu hình tường lửa UFW trên Server (Ubuntu/Debian). Giúp hệ thống luôn trong trạng thái an toàn cao nhất (mặc định đóng toàn bộ port) nhưng vẫn linh hoạt bật/tắt nhanh các cổng dịch vụ khi phát triển (Dev) hoặc triển khai (Production).

---

## 1. Các lệnh triển khai nhanh (Cheat Sheet)

* `make setup` — Khởi tạo hệ thống: Chặn toàn bộ, chỉ mở duy nhất cổng SSH.
* `make open <port>` — Mở một cổng dịch vụ (Tùy chọn mở cho tất cả hoặc chỉ 1 IP cụ thể).
* `make close <port>` — Đóng cổng dịch vụ (Tùy chọn xóa một hoặc nhiều luật truy cập cùng lúc).
* `make show` — Xem danh sách toàn bộ các IP đang được cấp phép riêng trên máy.
* `make show <port>` — Xem cấu hình chi tiết và danh sách đối tượng được phép vào cổng đó.
* `make status` — Xem trạng thái tường lửa chi tiết của hệ thống.

---

## 2. Hướng dẫn sử dụng chi tiết & Kết quả mẫu

### Bước 1: Thiết lập an toàn ban đầu
> **Lưu ý:** Chạy lệnh này ngay khi vừa khởi tạo máy ảo.

```bash
make setup
