# Định nghĩa các biến mặc định
SSH_PORT ?= 22
PORT ?= $(filter-out open close show,$(MAKECMDGOALS))

.PHONY: setup open close status show

# 1. Thiết lập ban đầu: Đóng hết, chỉ mở SSH và kích hoạt Firewall
setup:
	@echo "=== Đang thiết lập cấu hình tường lửa an toàn ==="
	@sudo ufw reset --force
	@sudo ufw default deny incoming
	@sudo ufw default allow outgoing
	@sudo ufw allow $(SSH_PORT)/tcp comment 'SSH Port'
	@sudo ufw --force enable
	@echo "=== Đã bật UFW: Đóng toàn bộ port, chỉ mở SSH ($(SSH_PORT)) ==="
	@sudo ufw status verbose

# 2. Mở port tương tác: Hỏi All hoặc IP
open:
	@if [ -z "$(PORT)" ]; then \
		echo "Lỗi: Vui lòng nhập port. Ví dụ: make open 3000"; \
		exit 1; \
	fi
	@echo "Bạn muốn mở port $(PORT) cho đối tượng nào?"
	@echo "1) Tất cả mọi người (All / Anywhere)"
	@echo "2) Chỉ một IP cụ thể"
	@read -p "Lựa chọn của bạn (1 hoặc 2): " choice; \
	if [ "$$choice" = "1" ]; then \
		sudo ufw allow $(PORT)/tcp comment 'Mở All cho Dev'; \
		echo "=== Đã MỞ port $(PORT) cho TẤT CẢ mọi người ==="; \
	elif [ "$$choice" = "2" ]; then \
		read -p "Nhập địa chỉ IP được phép truy cập: " target_ip; \
		if [ -z "$$target_ip" ]; then \
			echo "Lỗi: IP không được để trống!"; \
			exit 1; \
		fi; \
		read -p "Nhập ghi chú (Ví dụ: Nginx_Server): " note; \
		sudo ufw allow from $$target_ip to any port $(PORT) proto tcp comment "$$note"; \
		echo "=== Đã MỞ port $(PORT) chỉ cho duy nhất IP: $$target_ip ==="; \
	else \
		echo "Lựa chọn không hợp lệ. Hủy thao tác."; \
		exit 1; \
	fi
	@echo "--------------------------------------------------"
	@sudo ufw status | grep $(PORT)

# 3. Đóng port tương tác: Liệt kê các rule của port đó, cho phép chọn nhiều hoặc all
close:
	@if [ -z "$(PORT)" ]; then \
		echo "Lỗi: Vui lòng nhập port. Ví dụ: make close 3000"; \
		exit 1; \
	fi
	@echo "=== Đang quét các luật tường lửa cho port $(PORT) ==="
	@sudo ufw status numbered | grep -E " $(PORT)(/tcp|\s)" > /tmp/ufw_rules_$(PORT).txt || true
	@if [ ! -s /tmp/ufw_rules_$(PORT).txt ]; then \
		echo "Không tìm thấy bất kỳ luật nào đang mở cho port $(PORT)."; \
		rm -f /tmp/ufw_rules_$(PORT).txt; \
		exit 0; \
	fi
	@echo "Tìm thấy các luật sau đang áp dụng cho port $(PORT):"
	@echo "--------------------------------------------------"
	@awk '{print NR") " $$0}' /tmp/ufw_rules_$(PORT).txt
	@echo "all) Xóa TẤT CẢ các luật trên"
	@echo "--------------------------------------------------"
	@read -p "Nhập lựa chọn của bạn (Ví dụ: 'all' hoặc '1' hoặc chọn nhiều '1 3 4'): " select_opt; \
	if [ "$$select_opt" = "all" ]; then \
		echo "=== Đang xóa TOÀN BỘ luật của port $(PORT) ==="; \
		awk -F'[][]' '{print $$2}' /tmp/ufw_rules_$(PORT).txt | sort -nr | while read -r num; do \
			sudo ufw --force delete $$num; \
		done; \
		echo "=== Đã ĐÓNG hoàn toàn port $(PORT) ==="; \
	elif [ -n "$$select_opt" ]; then \
		echo "=== Đang xóa các luật được chọn ==="; \
		for idx in $$select_opt; do \
			line_num=$$(awk -v i=$$idx 'NR==i {print $$0}' /tmp/ufw_rules_$(PORT).txt | awk -F'[][]' '{print $$2}'); \
			if [ -n "$$line_num" ]; then \
				echo "$$line_num" >> /tmp/ufw_delete_nums_$(PORT).txt; \
			fi; \
		done; \
		if [ -f /tmp/ufw_delete_nums_$(PORT).txt ]; then \
			sort -nr /tmp/ufw_delete_nums_$(PORT).txt | while read -r num; do \
				sudo ufw --force delete $$num; \
			done; \
			rm -f /tmp/ufw_delete_nums_$(PORT).txt; \
			echo "=== Đã xóa thành công các luật được chọn ==="; \
		else \
			echo "Lựa chọn số thứ tự không hợp lệ."; \
		fi; \
	else \
		echo "Không có lựa chọn nào được nhập. Hủy thao tác."; \
	fi
	@rm -f /tmp/ufw_rules_$(PORT).txt
	@echo "--------------------------------------------------"
	@sudo ufw status

# 4. Xem trạng thái các port hiện tại
status:
	@sudo ufw status verbose

# 5. Xem danh sách IP được cấp phép HOẶC xem cấu hình chi tiết của một Port cụ thể
show:
	@if [ -n "$(PORT)" ]; then \
		echo "=== CẤU HÌNH CHI TIẾT CHO PORT: $(PORT) ==="; \
		echo "----------------------------------------------------------------------"; \
		sudo ufw status numbered | grep -E " $(PORT)(/tcp|\s)" || echo "Port $(PORT) hiện đang ĐÓNG hoàn toàn (Không có cấu hình nào)."; \
		echo "----------------------------------------------------------------------"; \
	else \
		echo "=== DANH SÁCH CÁC IP ĐƯỢC CẤP PHÉP TRUY CẬP ==="; \
		echo "Format: [Cổng/Giao thức] <- [Hành động] <- [Địa chỉ IP được phép] [Ghi chú]"; \
		echo "----------------------------------------------------------------------"; \
		sudo ufw status numbered | grep -E 'ALLOW IN|ALLOW' | grep -v 'Anywhere' || echo "Không có IP riêng biệt nào đang được cấp phép (Chỉ mở công khai hoặc đóng hết)."; \
		echo "----------------------------------------------------------------------"; \
	fi

# Mẹo để Makefile hiểu tham số dạng 'make open 3000' hay 'make show 3000' mà không bị báo lỗi thiếu rule
%:
	@:
