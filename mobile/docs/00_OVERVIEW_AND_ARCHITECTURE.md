# Sports Store Mobile (Phong cách Adidas - Chuẩn hóa Việt Nam)
## Tài liệu Kế hoạch & Kiến trúc Dự án (Project Overview & Architecture)

---

### 1. Giới thiệu Dự án
- **Tên dự án**: `sports-store-mobile`
- **Mục tiêu**: Xây dựng ứng dụng thương mại điện tử chuyên đồ thể thao cao cấp lấy cảm hứng từ giao diện hiện đại, mạnh mẽ của Adidas (Dark/Light tương phản cao, Typography đậm nét thể thao, banner hero tràn viền), tối ưu hóa trải nghiệm mua sắm theo chuẩn hành vi và hạ tầng thanh toán tại Việt Nam.
- **Quy mô đội ngũ**: 5 thành viên (Mô hình Feature / Domain Owner).
- **Thời lượng**: 3 Sprints chính + Backlog (P1 & P2).

---

### 2. Định hướng Thiết kế & Chuẩn hóa Việt Nam (Localization)
1. **Phong cách Adidas DNA**:
   - Tông màu chủ đạo: Đen tuyền (#000000), Trắng tinh khôi (#FFFFFF), Điểm nhấn xám thể thao (#767677) và neon highlight (Cam/Vàng thể thao cho nút CTA/Khuyến mãi).
   - Typography: Font không chân góc cạnh, đậm nét (dòng font Oswald/Barlow/Montserrat hoặc tương đương), hiển thị rõ số size giày, bảng size US/UK/VN.
   - Thẻ sản phẩm: Tỉ lệ ảnh 1:1 hoặc 3:4 sắc nét, badge phân loại (Originals, Performance, Best Seller, New).
2. **Chuẩn hóa thị trường Việt Nam**:
   - **Tiền tệ**: Định dạng chuẩn VNĐ (`1.950.000 ₫`), dấu chấm phân cách hàng nghìn.
   - **Sổ địa chỉ 3 cấp**: Tích hợp danh mục hành chính Việt Nam (Tỉnh/Thành phố -> Quận/Huyện -> Phường/Xã) kèm số nhà, tên đường.
   - **Phương thức thanh toán**:
     - COD (Thanh toán tiền mặt khi giao hàng) - phương thức cốt lõi.
     - Cổng thanh toán trực tuyến: VNPAY / MoMo / ZaloPay (App-to-App hoặc Webview sandbox).
   - **Số điện thoại & Đăng nhập**: Hỗ trợ định dạng số di động Việt Nam (+84 / 09x, 03x, 07x, 08x).
   - **Voucher & Khuyến mãi**: Mã giảm giá phần trăm tối đa (VD: Giảm 20% tối đa 100k), miễn phí vận chuyển (Freeship Extra).

---

### 3. Công nghệ & Kiến trúc Kỹ thuật (Technical Stack)
- **Framework**: Flutter (Dart >= 3.x)
- **State Management**: `flutter_bloc` & `cubit` (quản lý state tách biệt Event - State, phục vụ kiểm thử dễ dàng).
- **Service Locator / Dependency Injection**: `get_it` + `injectable`
- **Mạng & Gọi API**: `dio` kèm Interceptors (tự động gắn Bearer Token, làm mới token, xử lý timeout/lỗi mạng chuẩn tiếng Việt).
- **Bộ nhớ cục bộ (Local Cache trên Mobile)**: `shared_preferences` (lưu JWT Access/Refresh Token, Theme, gần đây xem) & `flutter_secure_storage` (cho credentials).
- **Cơ sở dữ liệu Hệ thống (Backend Database)**: **Microsoft SQL Server (MSSQL)** (Lưu trữ toàn bộ dữ liệu người dùng, sản phẩm, đơn hàng, danh mục, voucher, đánh giá; Flutter Mobile tương tác thông qua RESTful API / Dio).
- **Kiểm thử**: `flutter_test`, `bloc_test`, `mocktail` cho Unit Test & Widget Test.
- **Phân tích mô hình dữ liệu**: `freezed` + `json_serializable` (bảo đảm immutability và type safety).

---

### 4. Kiến trúc Thư mục (Feature-First Clean Architecture)
Để giảm thiểu tối đa xung đột mã nguồn (Merge Conflict) cho 5 lập trình viên, dự án được tổ chức theo từng tính năng độc lập:

```text
lib/
├── app/
│   ├── app.dart                   # MaterialApp cấu hình routes, theme, bloc providers
│   ├── app_bloc_observer.dart     # Logger theo dõi toàn bộ state transitions
│   └── routes/                    # GoRouter hoặc AutoRoute định tuyến màn hình
├── core/
│   ├── constants/                 # Màu sắc, font chữ, asset paths, API endpoints
│   ├── errors/                    # Exception & Failure classes
│   ├── network/                   # Dio client setup, interceptors, error handler
│   ├── theme/                     # Adidas dark/light theme, typography
│   ├── utils/                     # Format tiền tệ VNĐ, ngày tháng, validate SĐT
│   └── widgets/                   # Common UI: AppButton, AppTextField, LoadingDialog
├── features/
│   ├── auth/                      # Đăng nhập, đăng ký, quên mật khẩu, token cache
│   │   ├── data/ (models, datasources, repositories)
│   │   ├── domain/ (entities, repository_interfaces, usecases)
│   │   └── presentation/ (bloc, screens, widgets)
│   ├── product/                   # Danh sách sản phẩm, lọc, tìm kiếm, chi tiết
│   ├── cart/                      # Giỏ hàng, tính tổng tiền, số lượng
│   ├── checkout_order/            # Thanh toán (COD/VNPAY), lịch sử đơn hàng
│   ├── profile_address/           # Thông tin cá nhân, sổ địa chỉ 3 cấp VN
│   ├── review_rating/             # Đánh giá sao, viết nhận xét sản phẩm
│   ├── voucher/                   # Quản lý voucher, áp dụng mã giảm giá
│   └── admin/                     # Quản lý sản phẩm, danh mục, duyệt đơn hàng
└── main.dart                      # Điểm khởi chạy ứng dụng
```
