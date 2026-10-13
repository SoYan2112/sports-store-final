# Sports Store Mobile (Phong cách Fresh & Vibrant Sporty - Chuẩn hóa Việt Nam)
## Tài liệu Kế hoạch & Kiến trúc Dự án (Project Overview & Architecture)

---

### 1. Giới thiệu Dự án
- **Tên dự án**: `sports-store-mobile`
- **Mục tiêu**: Xây dựng ứng dụng thương mại điện tử chuyên đồ thể thao cao cấp đa thương hiệu (Multi-brand: Nike, Adidas, Puma, Reebok, Under Armour...) với giao diện hiện đại, tươi sáng, trẻ trung và tràn đầy năng lượng (Fresh & Vibrant Light Theme, Tone Cam năng động `#FF6B00` / `#FF5722` làm điểm nhấn, thẻ sản phẩm bo tròn mềm mại 16-24px, đổ bóng mờ tinh tế), tối ưu hóa trải nghiệm mua sắm theo chuẩn hành vi và hạ tầng thanh toán tại Việt Nam.
- **Quy mô đội ngũ**: 5 thành viên (Mô hình Feature / Domain Owner).
- **Thời lượng**: 3 Sprints chính + Backlog (P1 & P2).

---

### 2. Định hướng Thiết kế & Chuẩn hóa Việt Nam (Localization)
1. **Phong cách Fresh & Vibrant Light Theme (Đa thương hiệu thể thao)**:
   - **Tông màu chủ đạo (Color Palette)**:
     - **Primary Accent (Cam năng động)**: Mã màu `#FF6B00` / `#FF5722` - dùng cho toàn bộ nút Call-to-Action chính ("Add to cart", "Proceed to Checkout"), nút tăng/giảm số lượng, size giày đang chọn, icon yêu thích (Wishlist), giá sản phẩm và các thông báo nổi bật.
     - **Nền ứng dụng (App Background)**: Trắng / Xám sáng siêu nhạt (`#F8F9FA` - `#FFFFFF`), mang lại cảm giác thoáng đãng, sạch sẽ, thể thao tươi mới và tràn đầy năng lượng tích cực.
     - **Bề mặt thẻ (Surface / Cards)**: Nền trắng tinh khôi (`#FFFFFF`), kết hợp hiệu ứng đổ bóng mờ nhẹ nhàng (`elevation` 2-4dp mềm mại, shadow blur dịu mắt), tuyệt đối không dùng viền đen thô cứng.
     - **Hệ thống chữ (Text Hierarchy)**: Đen xám hiện đại (`#1A1A1A` / `#212121`) cho tiêu đề chính tạo độ tương phản cao trên nền sáng; Xám trung tính (`#666666` / `#8E8E93`) cho phụ đề, nhãn phụ và văn bản mô tả.
     - **Màu phụ trợ (Semantic / Badges)**: Xanh lá (`#4CAF50` - Freeship / Còn hàng), Đỏ cam (`#FF3D00` - Hot Deal / Sale %), Cam hổ phách (`#FFA000` - Best Seller / Đánh giá sao).
   - **Typography (Kiểu chữ)**:
     - Font chữ chủ đạo: **Poppins** hoặc **Plus Jakarta Sans** (họ font Sans-serif hình học bo tròn, hiện đại, nét chữ thân thiện, thanh thoát và thể thao, độ đọc xuất sắc trên màn hình di động).
     - Phân cấp hiển thị rõ ràng: Headline đậm vừa phải (SemiBold/Bold), Body Regular, số tiền VNĐ và size giày hiển thị to bản, trực quan.
   - **Quy chuẩn Thẻ & Thành phần Giao diện (Card Style & Components)**:
     - **Thẻ sản phẩm (Product Card)**: Bo góc lớn mềm mại (BorderRadius 16 - 24px), ảnh sản phẩm đặt trên nền card sạch sẽ với góc nhìn nổi bật (hỗ trợ vòng xoay trực quan 360°/đa góc chụp).
     - **Brand Chips & Bộ lọc**: Dạng viên thuốc (Pill shape) hoặc hình tròn bo cong, hiển thị logo nhãn hàng (Nike, Adidas, Puma, Reebok, Under Armour...) trên nền card trắng; khi chọn (active) sẽ highlight viền và màu cam nổi bật.
     - **Bộ chọn kích cỡ (Size Selector)**: Nút tròn/bo góc với đường kính chuẩn ngón tay bấm, kích thước đang chọn chuyển sang nền Cam chữ trắng nổi bật.
     - **Nút tương tác (Buttons & CTA)**: Bo góc tròn dạng Pill Button (BorderRadius 24-30px), màu Cam rực rỡ với hiệu ứng phản hồi xúc giác/micro-animation mượt mà khi chạm.
   - **Mô hình Cửa hàng Đa Thương hiệu (Multi-brand Store)**:
     - Danh mục hỗ trợ đa dạng hãng thể thao hàng đầu thế giới (Nike, Adidas, Puma, Reebok, Under Armour...).
     - Hệ thống Badges phân loại sản phẩm: `New`, `Hot`, `Best Seller`, `Sale %`.

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
│   ├── theme/                     # Fresh vibrant light theme, typography, colors
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
