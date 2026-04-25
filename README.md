# 🏥 Pharmacy Admin System - Quản Lý Nhà Thuốc Hiện Đại

Dự án chuyên đề tốt nghiệp xây dựng hệ thống quản lý kho và bán hàng thông minh dành cho nhà thuốc, hỗ trợ cả bán lẻ tại quầy (POS) và quản lý đơn hàng trực tuyến.

---

## 👥 Thành Viên Thực Hiện
- **Lê Văn Tùng** 
- **Lý Ngọc Quân**

---

## 🚀 Giới Thiệu Chung
**Pharmacy Admin System** là giải pháp phần mềm toàn diện giúp tối ưu hóa quy trình vận hành nhà thuốc. Với giao diện hiện đại (Material 3) và dữ liệu thời gian thực (Real-time), hệ thống giúp chủ cửa hàng kiểm soát chặt chẽ doanh thu, hàng tồn kho và đơn hàng chỉ trên một nền tảng duy nhất.

---

## ✨ Các Tính Năng Chính

### 1. 📊 Bảng Điều Khiển Tổng Quan (Dashboard)
- Theo dõi nhanh tổng doanh thu, số lượng sản phẩm và đơn hàng chờ duyệt.
- Biểu đồ tăng trưởng trực quan giúp đánh giá tình hình kinh doanh.

### 2. 📦 Quản Lý Kho Hàng (Inventory)
- Thêm, sửa, xóa thông tin thuốc với đầy đủ hình ảnh (URL).
- Hệ thống cảnh báo tự động khi số lượng tồn kho xuống mức thấp (dưới 10 đơn vị).
- Tìm kiếm sản phẩm thông minh theo tên hoặc danh mục.

### 3. 🛒 Hệ Thống Bán Hàng Tại Quầy (POS)
- Giao diện lưới sản phẩm trực quan, hỗ trợ thêm vào giỏ hàng nhanh chóng.
- Tự động trừ kho ngay khi thanh toán.
- Xuất hóa đơn điện tử lưu trữ trực tiếp trên Cloud.

### 4. 🚚 Quản Lý Đơn Hàng Online
- Tiếp nhận và xử lý đơn hàng từ ứng dụng khách hàng.
- Quy trình duyệt đơn 3 bước: **Chờ Duyệt -> Đang Giao -> Hoàn Thành**.
- Cập nhật trạng thái đơn hàng thời gian thực.

### 5. 📈 Thống Kê Doanh Thu
- Lọc doanh thu linh hoạt theo thời gian: **Hôm nay, Tuần này, Tháng này**.
- Biểu đồ đường (Line Chart) theo dõi biến động doanh thu chi tiết.

---

## 🛠 Công Nghệ Sử Dụng
- **Ngôn ngữ:** Dart
- **Framework:** [Flutter](https://flutter.dev) (Hỗ trợ đa nền tảng: Android, iOS, Web, Desktop)
- **Backend:** [Firebase](https://firebase.google.com)
  - **Firestore:** Lưu trữ dữ liệu NoSQL thời gian thực.
  - **Authentication:** Quản lý đăng nhập/đăng ký admin bảo mật.
- **Thư viện chính:**
  - `fl_chart`: Xây dựng biểu đồ chuyên nghiệp.
  - `firebase_core`, `cloud_firestore`: Kết nối hệ sinh thái Google Cloud.

---

## 📁 Cấu Trúc Mã Nguồn (Clean Architecture)
Dự án đã được phân tách thành các module riêng biệt để dễ dàng bảo trì và nâng cấp:
```text
lib/
  ├── screens/                # Các màn hình chức năng
  │   ├── login_screen.dart   # Đăng nhập & Đăng ký
  │   ├── overview_screen.dart# Dashboard tổng quan
  │   ├── inventory_screen.dart # Quản lý kho
  │   ├── pos_screen.dart     # Bán hàng tại quầy
  │   ├── order_manager.dart  # Quản lý đơn online
  │   └── revenue_screen.dart # Thống kê doanh thu
  └── main.dart               # Cấu hình chính và Điều hướng (Router)
```

---

## ⚙️ Hướng Dẫn Cài Đặt
1. **Clone project:**
   ```bash
   git clone https://github.com/LeTung2610/Flutter.git
   ```
2. **Cài đặt thư viện:**
   ```bash
   flutter pub get
   ```
3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

## 🖼️ Cấu Hình Upload Ảnh Web (Proxy, tránh lỗi CORS)
Với Flutter Web, không nên gọi trực tiếp ImgBB từ trình duyệt vì dễ gặp lỗi `Failed to fetch` (CORS). Dự án đã có sẵn Cloud Function proxy:

1. Cài Firebase CLI (nếu chưa có):
  ```bash
  npm i -g firebase-tools
  firebase login
  ```
2. Deploy function trong thư mục dự án:
  ```bash
  cd functions
  npm install
  firebase functions:secrets:set IMGBB_API_KEY
  npm run deploy
  ```
3. Lấy URL function dạng:
  `https://us-central1-pharmacy-online-9bcf5.cloudfunctions.net/uploadImageToImgBB`
4. Dán URL vào biến `uploadProxyUrl` trong [lib/config/image_upload_config.dart](lib/config/image_upload_config.dart).

Sau khi cấu hình proxy, app sẽ upload ảnh qua backend (an toàn key và ổn định trên web hơn).

---
*Bản quyền thuộc về nhóm sinh viên thực hiện chuyên đề tốt nghiệp.*
