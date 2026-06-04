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
```
Kết quả mẫu:
```bash
=== Đang thiết lập cấu hình tường lửa an toàn ===
=== Đã bật UFW: Đóng toàn bộ port, chỉ mở SSH (22) ===
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                   # SSH Port
```
(Nếu sử dụng cổng SSH tùy chỉnh, ví dụ 2289, hãy chạy: make setup SSH_PORT=2289)

### Bước 2: Mở cổng dịch vụ khi Dev hoặc Deploy
Khi bạn chạy một dịch vụ mới (ví dụ cổng 3000), sử dụng lệnh:
```bash
make open 3000
```
Kịch bản 1: Mở công khai cho tất cả mọi người (All)
```bash
Bạn muốn mở port 3000 cho đối tượng nào?
1) Tất cả mọi người (All / Anywhere)
2) Chỉ một IP cụ thể
Lựa chọn của bạn (1 hoặc 2): 1
=== Đã MỞ port 3000 cho TẤT CẢ mọi người ===
```
Kịch bản 2: Chỉ mở cho 1 IP tin cậy (Ví dụ: IP của Server Nginx Gateway)
```
Bạn muốn mở port 3000 cho đối tượng nào?
1) Tất cả mọi người (All / Anywhere)
2) Chỉ một IP cụ thể
Lựa chọn của bạn (1 hoặc 2): 2
Nhập địa chỉ IP được phép truy cập: 1.2.3.4
Nhập ghi chú (Ví dụ: Nginx_Server): Nginx_Gateway
=== Đã MỞ port 3000 chỉ cho duy nhất IP: 1.2.3.4 ===
```
